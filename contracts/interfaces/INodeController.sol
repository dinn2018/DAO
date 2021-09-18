// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface INodeController {

	function addNode(uint256 nodeId, uint256 period, bytes32 region) external;

	function removeNode(uint256 nodeId) external;

	function punishNode(uint256 nodeId, uint256 amount) external;

	function exitNode(uint256 nodeId) external;

	function endNode(uint256 nodeId) external;

}
