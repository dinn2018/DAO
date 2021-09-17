// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface INodes {

	function add(uint256 nodeId, uint256 minPledge, bytes32 region) external;

	function remove(uint256 nodeId) external;

	function transfer(uint256 nodeId, address to) external;

	function pledge(uint256 nodeId, address to) external payable;

	function punish(uint256 nodeId, uint256 amount) external;

	function exit(address from, uint256 nodeId) external;

	function exists(uint256 nodeId) external view returns (bool);

	function ownerOf(uint256 nodeId) external view returns(address);

}
