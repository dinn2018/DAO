// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';

import './interfaces/INodeController.sol';
import './interfaces/INodes.sol';
import './interfaces/INodeLending.sol';

abstract contract NodeController is INodeController, Ownable {

	INodes public nodes;

	INodeLending public lending;

	function setInterface(INodes nodes_, INodeLending lending_) external onlyOwner {
		if (address(nodes) == address(0)) {
			nodes = nodes_;
		}
		if (address(lending) == address(0)) {
			lending = lending_;
		}
	}

	function addNode(uint256 nodeId, uint256 period, bytes32 region) external override onlyOwner {
		nodes.add(nodeId, period, region);
	}

	function removeNode(uint256 nodeId) external override onlyOwner {
		nodes.remove(nodeId);
	}

	function punishNode(uint256 nodeId, uint256 amount) external override onlyOwner {
		address owner = nodes.ownerOf(nodeId);
		uint256 loan = lending.realisedLoans(owner, nodeId);
		nodes.punish(nodeId, amount);
		uint256 leftPledge = nodes.get(nodeId).pledge;
		if (loan >= leftPledge) {
			nodes.exit(nodeId, leftPledge);
			lending.mortgageEnd(nodeId);
		}
	}

	function exitNode(uint256 nodeId) external override {
		address owner = nodes.ownerOf(nodeId);
		require(msg.sender == owner || nodes.mortgageEndBlock(nodeId) < block.number, 'NodeController: can not exit.');
		uint256 loan = lending.realisedLoans(owner, nodeId);
		uint256 pledge = nodes.get(nodeId).pledge;
		require(pledge >= loan, 'NodeController: not enough pledge to pay loan.');
		nodes.exit(nodeId, loan);
		lending.mortgageEnd(nodeId);
	}

}
