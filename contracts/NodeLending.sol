// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import './interfaces/INodes.sol';
import './interfaces/INodeLending.sol';
import './interfaces/IController.sol';

contract NodeLending is INodeLending, Ownable {
	using SafeMath for uint256;

	mapping(address => mapping(uint256 => uint256)) public mortgages;

	mapping(address => mapping(uint256 => uint256)) public override unrealisedLoans;

	mapping(address => mapping(uint256 => uint256)) public override realisedLoans;

	uint256 private totalNodeLoans;

	INodes public immutable nodes;

	IController public immutable controller;

	constructor(IController controller_, INodes nodes_) {
		controller = controller_;
		nodes = nodes_;
	}

	function mortgage(
		address to,
		uint256 nodeId,
		uint256 amount
	) external override validataNode(nodeId) {
		require(controller.canMortgageNode(msg.sender), 'NodeLending: no auth to mortgage.');
		require(nodes.ownerOf(nodeId) == address(nodes), 'NodeLending: invalid node owner.');
		mortgages[to][nodeId] = mortgages[to][nodeId].add(amount);
	}

	function unrealise(
		address to,
		uint256 nodeId,
		uint256 amount
	) external override validataNode(nodeId) {
		require(nodes.ownerOf(nodeId) == address(nodes), 'NodeLending: node has been owned.');
		require(controller.canLend(msg.sender), 'NodeLending: no auth to borrow.');
		require(realisedLoans[to][nodeId] == 0, 'NodeLending: loan not paid.');
		uint256 loan = unrealisedLoans[to][nodeId].add(amount);
		require(maxLoan(to, nodeId) >= loan, 'NodeLending: exceed max loans.');
		unrealisedLoans[to][nodeId] = loan;
	}

	function realise(address to, uint256 nodeId) external override validataNode(nodeId) {
		require(nodes.ownerOf(nodeId) == address(nodes), 'NodeLending: node has been owned.');
		require(controller.canLend(msg.sender), 'NodeLending: no auth to borrow.');
		uint256 loan = unrealisedLoans[to][nodeId];
		unrealisedLoans[to][nodeId] = unrealisedLoans[to][nodeId].sub(loan);
		realisedLoans[to][nodeId] = realisedLoans[to][nodeId].add(loan);
		totalNodeLoans = totalNodeLoans.add(loan);
	}

	function clear(address to, uint256 nodeId) external override validataNode(nodeId) {
		require(controller.canMortgageNode(msg.sender), 'NodeLending: no auth to clear mortgage.');
		delete mortgages[to][nodeId];
		delete unrealisedLoans[to][nodeId];
	}

	function mortgageEnd(uint256 nodeId) external override validataNode(nodeId) {
		require(controller.canEndNode(msg.sender), 'NodeLending: no auth to end mortgage.');
		address to = nodes.ownerOf(nodeId);
		uint256 loan = realisedLoans[to][nodeId];
		totalNodeLoans = totalNodeLoans.sub(loan);
		realisedLoans[to][nodeId] = 0;
		mortgages[to][nodeId] = 0;
	}

	function totalLoans() external view override returns (uint256) {
		return totalNodeLoans;
	}

	function mortgageOf(address to, uint256 nodeId) external view override returns (uint256) {
		return mortgages[to][nodeId];
	}

	function maxLoan(address to, uint256 nodeId) public view returns (uint256) {
		uint256 amount = mortgages[to][nodeId];
		uint256 unrealisedRewardInOneYear = controller.perblockReward().mul(nodes.get(nodeId).meta.period);
		return unrealisedRewardInOneYear.add(amount).div(controller.RMAX()).mul(controller.NUMERATOR());
	}

	modifier validataNode(uint256 nodeId) {
		require(nodes.exists(nodeId), 'Nodes: node not found.');
		_;
	}

}
