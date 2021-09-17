// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface INodeController {

	function addNode(uint256 nodeId, uint256 minPledge, bytes32 region) external;

	function removeNode(uint256 nodeId) external;

}
