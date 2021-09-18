// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface INodes {

	struct Meta {
		uint256 period;
		bytes32 region;
	}

	struct Node {
		Meta meta;
		uint256 mortgageStartBlock;
		uint256 pledge;
		address owner;
	}

	function add(uint256 nodeId, uint256 period, bytes32 region) external;

	function remove(uint256 nodeId) external;

	function mortgage(uint256 nodeId, address to) external payable;

	function pledge(uint256 nodeId, address to) external payable;

	function punish(uint256 nodeId, uint256 amount) external;

	function exit(uint256 nodeId, uint256 burned) external;

	function mortgageEndBlock(uint256 nodeId) external view returns(uint256);

	function exists(uint256 nodeId) external view returns (bool);

	function ownerOf(uint256 nodeId) external view returns(address);

	function get(uint256 nodeId) external view returns (Node memory);

}
