// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import './libraries/EnumerableNodeId.sol';
import './interfaces/INodes.sol';
import './interfaces/INodeAuthority.sol';

contract Nodes is INodes {
	using SafeMath for uint256;

	using EnumerableNodeId for EnumerableNodeId.Map;

	mapping(address => EnumerableNodeId.Map) private balances;

	mapping(uint256 => Node) public nodes;

	INodeAuthority public authority;

	event Add(address indexed from, address indexed to, uint256 indexed nodeId);

	event Remove(address indexed from, uint256 indexed nodeId);

	event Punish(uint256 indexed nodeId, uint256 amount);

	event Mortgage(address indexed from, address indexed to, uint256 indexed nodeId, uint256 pledge);

	event MortgageEnd(address indexed from, address indexed to, uint256 indexed nodeId, uint256 pledge);

	event Pledge(address indexed from, address indexed to, uint256 indexed nodeId, uint256 pledge);

	event Exit(address indexed from, address indexed to, uint256 indexed nodeId);

	constructor(INodeAuthority authority_) {
		authority = authority_;
	}

	function add(
		uint256 nodeId,
		uint256 period,
		bytes32 region
	) external override {
		require(authority.canAddNode(msg.sender), 'Nodes: no auth to add node.');
		require(!exists(nodeId), 'Nodes: node exsists.');

		balances[address(this)].set(nodeId, nodeId);
		nodes[nodeId].meta = Meta(period, region);
		nodes[nodeId].owner = address(this);

		emit Add(address(0), address(this), nodeId);
	}

	function remove(uint256 nodeId) external override validataNode(nodeId) {
		require(authority.canRemoveNode(msg.sender), 'Nodes: no auth to remove node.');
		require(nodes[nodeId].owner == address(this), 'Nodes: node not exited.');
		balances[address(this)].remove(nodeId);
		delete nodes[nodeId];

		emit Remove(address(this), nodeId);
	}

	// mortgage pleage and get node.
	function mortgage(uint256 nodeId, address mortgager) external payable override validataNode(nodeId) {
		require(authority.canMortgageNode(msg.sender), 'Nodes: no auth to mortgage node.');
		require(nodes[nodeId].owner == address(this), 'Nodes: node has been assigned');
		_transfer(address(this), mortgager, nodeId);
		nodes[nodeId].pledge = nodes[nodeId].pledge.add(msg.value);
		nodes[nodeId].mortgageStartTime = block.timestamp;

		emit Mortgage(msg.sender, mortgager, nodeId, msg.value);
	}

	// punish node.
	function punish(uint256 nodeId, uint256 amount) external override validataNode(nodeId) {
		require(authority.canPunishNode(msg.sender), 'Nodes: no auth to punish node.');
		uint256 punished = amount > nodes[nodeId].pledge? amount : nodes[nodeId].pledge;
		nodes[nodeId].pledge = nodes[nodeId].pledge.sub(punished);
		// burned
		payable(address(0)).transfer(punished);

		emit Punish(nodeId, punished);
	}

	// add pledge
	function pledge(uint256 nodeId, address mortgager) external payable override validataNode(nodeId) {
		require(nodes[nodeId].owner != address(this), 'Nodes: node not assigned');
		nodes[nodeId].pledge = nodes[nodeId].pledge.add(msg.value);

		emit Pledge(msg.sender, mortgager, nodeId, msg.value);
	}

	// node exit.
	function exit(uint256 nodeId, uint256 burned) external override validataNode(nodeId) {
		require(authority.canExitNode(msg.sender), 'Nodes: no auth to exit.');
		require(mortgageEndTime(nodeId) >= block.number, 'Nodes: out of mortgage periord.');
		address owner = ownerOf(nodeId);
		_transfer(owner, address(this), nodeId);
		nodes[nodeId].mortgageStartTime = 0;
		nodes[nodeId].pledge = nodes[nodeId].pledge.sub(burned);
		if (burned > 0) {
			payable(address(0)).transfer(burned);
		}
		if (nodes[nodeId].pledge > 0) {
			payable(owner).transfer(nodes[nodeId].pledge);
		}
		emit Exit(owner, address(this), nodeId);
	}

	function mortgageEndTime(uint256 nodeId) public view override validataNode(nodeId) returns(uint256) {
		Node memory node = nodes[nodeId];
		require(node.owner != address(this) && node.mortgageStartTime != 0, 'Nodes: node is not mortgaged');
		return node.mortgageStartTime.add(node.meta.period);
	}

	function ownerOf(uint256 nodeId) public view override returns (address) {
		return nodes[nodeId].owner;
	}

	function get(uint256 nodeId) external view override returns (Node memory) {
		require(exists(nodeId), 'Nodes: nonexistent node.');
		return nodes[nodeId];
	}

	function balanceOf(address from) external view returns (uint256) {
		return balances[from].length();
	}

	function at(address from, uint256 index) external view returns (uint256, Node memory) {
		(uint256 key, uint256 nodeId) = balances[from].at(index);
		return (key, nodes[nodeId]);
	}

	function exists(uint256 nodeId) public view override returns (bool) {
		return nodes[nodeId].owner != address(0);
	}

	function _transfer(
		address from,
		address to,
		uint256 nodeId
	) internal {
		require(nodes[nodeId].owner == from, 'Nodes: invalid node owner');
		require(to != address(0), 'Nodes: transfer to the zero address.');
		require(balances[from].contains(nodeId), 'Nodes: node is not owned.');

		balances[from].remove(nodeId);
		balances[to].set(nodeId, nodeId);
		nodes[nodeId].owner = to;
	}

	modifier validataNode(uint256 nodeId) {
		require(exists(nodeId), 'Nodes: node not found.');
		_;
	}
}
