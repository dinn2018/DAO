// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import './libraries/EnumerableNodeId.sol';
import './interfaces/IController.sol';

contract Nodes is Ownable {
	using SafeMath for uint256;

	using EnumerableNodeId for EnumerableNodeId.Map;

	struct Meta {
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

	event Add(address indexed from, address indexed to, uint256 indexed nodeId);

	event Pledge(address indexed from, address indexed to, uint256 indexed nodeId, uint256 pledge);

	event Exit(address indexed from, address indexed to, uint256 indexed nodeId);

	constructor(address controller) {
		transferOwnership(controller);
	}

	function add(
		uint256 nodeId,
		bytes32 region
	) external onlyOwner {
		require(!exists(nodeId), 'Nodes: nodeId exsists.');

		address nodeOwner = owner();
		balances[nodeOwner].set(nodeId, nodeId);
		nodes[nodeId].meta = Meta(region);
		nodes[nodeId].owner = nodeOwner;

		emit Add(address(0), nodeOwner, nodeId);
	}

	function pledge(
		uint256 nodeId,
		address to,
		uint256 pledge_
	) external onlyOwner {
		_transfer(owner(), to, nodeId);
		nodes[nodeId].pledge = nodes[nodeId].pledge.add(pledge_);

		emit Pledge(owner(), to, nodeId, pledge_);
	}

	function punish(uint256 nodeId, uint256 amount) external onlyOwner {
		require(nodes[nodeId].pledge > amount, 'Nodes: not enough pledge to punish.');
		nodes[nodeId].pledge = nodes[nodeId].pledge.sub(amount);
	}

	function exit(address from, uint256 nodeId) external onlyOwner {
		_transfer(from, owner(), nodeId);

		emit Exit(from, owner(), nodeId);
	}

	function balanceOf(address from) external view returns (uint256) {
		return balances[from].length();
	}

	function at(address from, uint256 index) external view returns (uint256, Node memory) {
		(uint256 key, uint256 nodeId) = balances[from].at(index);
		return (key, nodes[nodeId]);
	}

	function exists(uint256 nodeId) public view returns (bool) {
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
