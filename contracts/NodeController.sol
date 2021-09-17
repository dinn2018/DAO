// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';

import './interfaces/INodeController.sol';
import './interfaces/INodes.sol';

abstract contract NodeController is INodeController, Ownable {

	INodes public nodes;

	function setNode(INodes nodes_) external onlyOwner {
		nodes = nodes_;
	}

	function addNode(uint256 nodeId, uint256 minPledge, bytes32 region) external override onlyOwner {
		nodes.add(nodeId, minPledge, region);
	}

	function removeNode(uint256 nodeId) external override onlyOwner {
		nodes.remove(nodeId);
	}

}
