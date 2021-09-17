// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import './libraries/EnumerableNodeId.sol';
import './interfaces/INodes.sol';
import './interfaces/INodeAuthority.sol';

contract Nodes is INodes, Ownable {
	using SafeMath for uint256;

	using EnumerableNodeId for EnumerableNodeId.Map;

	struct Meta {
		uint256 minPledge;
		bytes32 region;
	}

	struct Node {
		Meta meta;
		uint256 pledge;
		address owner;
	}

	mapping(address => EnumerableNodeId.Map) private balances;

	mapping(uint256 => Node) public nodes;

	uint256 public totalLoans;

	INodeAuthority public authority;

	event Add(address indexed from, address indexed to, uint256 indexed nodeId);

	event Remove(address indexed from, uint256 indexed nodeId);

	event Transfer(address indexed from, address indexed to, uint256 indexed nodeId);

	event Punish(uint256 indexed nodeId, uint256 amount);

	event Pledge(address indexed from, address indexed to, uint256 indexed nodeId, uint256 pledge);

	event Exit(address indexed from, address indexed to, uint256 indexed nodeId);

	constructor(INodeAuthority authority_) {
		authority = authority_;
	}

	function add(
		uint256 nodeId,
		uint256 minPledge,
		bytes32 region
	) external override onlyOwner {
		require(authority.canAddNode(msg.sender), 'Nodes: no auth to add node.');
		require(!exists(nodeId), 'Nodes: nodeId exsists.');

		balances[address(this)].set(nodeId, nodeId);
		nodes[nodeId].meta = Meta(minPledge, region);
		nodes[nodeId].owner = address(this);

		emit Add(address(0), address(this), nodeId);
	}

	function remove(uint256 nodeId) external override onlyOwner {
		require(authority.canRemoveNode(msg.sender), 'Nodes: no auth to remove node.');
		require(nodes[nodeId].owner == address(this), 'Nodes: node not exited.');
		balances[address(this)].remove(nodeId);
		delete nodes[nodeId];

		emit Remove(address(this), nodeId);
	}

	function transfer(uint256 nodeId, address to) external override onlyOwner {
		require(authority.canTransferNode(msg.sender), 'Nodes: no auth to transfer node.');
		_transfer(address(this), to, nodeId);

		emit Transfer(address(this), to, nodeId);
	}

	function punish(uint256 nodeId, uint256 amount) external override onlyOwner {
		require(authority.canPunishNode(msg.sender), 'Nodes: no auth to punish node.');
		require(nodes[nodeId].pledge > amount, 'Nodes: not enough pledge to punish.');
		nodes[nodeId].pledge = nodes[nodeId].pledge.sub(amount);

		emit Punish(nodeId, amount);
	}

	function pledge(uint256 nodeId, address to) external payable override onlyOwner {
		require(exists(nodeId), 'Nodes: node not found.');
		require(nodes[nodeId].owner != address(this), 'Nodes: node not assigned');

		nodes[nodeId].pledge = nodes[nodeId].pledge.add(msg.value);
		emit Pledge(msg.sender, to, nodeId, msg.value);
	}

	function exit(address from, uint256 nodeId) external override onlyOwner {
		_transfer(from, address(this), nodeId);

		emit Exit(from, address(this), nodeId);
	}

	function ownerOf(uint256 nodeId) external view override returns (address) {
		return nodes[nodeId].owner;
	}

	function balanceOf(address from) external view returns (uint256) {
		return balances[from].length();
	}

	function at(address from, uint256 index) external view returns (uint256, Node memory) {
		(uint256 key, uint256 nodeId) = balances[from].at(index);
		return (key, nodes[nodeId]);
	}

	function get(uint256 nodeId) external view returns (Node memory) {
		return nodes[nodeId];
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
}
