// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import './interfaces/INodes.sol';
import './interfaces/IStake.sol';
import './interfaces/INodeLending.sol';
import './interfaces/ILendingAuthority.sol';

contract NodeLending is INodeLending, Ownable {
	using SafeMath for uint256;

	struct Mortgage {
		uint256 amount;
		uint256 apy;
	}

	mapping(address => mapping(uint256 => Mortgage)) public mortgages;

	mapping(address => mapping(uint256 => uint256)) public override unrealisedLoans;

	mapping(address => mapping(uint256 => uint256)) public override realisedLoans;

	uint256 private totalNodeLoans;

	IStake public immutable stake;

	INodes public immutable nodes;

	ILendingAuthority public immutable lendingAuthority;

	constructor(
		ILendingAuthority lendingAuthority_,
		IStake stake_,
		INodes nodes_
	) {
		lendingAuthority = lendingAuthority_;
		stake = stake_;
		nodes = nodes_;
	}

	function mortgage(
		address to,
		uint256 nodeId,
		uint256 amount
	) external override {
		require(nodes.exists(nodeId), 'NodeLending: nonexistent node.');
		require(nodes.ownerOf(nodeId) == address(nodes) || nodes.ownerOf(nodeId) == to, 'NodeLending: invalid node owner.');
		require(realisedLoans[to][nodeId] == 0, 'NodeLending: loan not paid.');
		require(lendingAuthority.canMortgage(msg.sender), 'NodeLending: no auth to mortgage.');
		mortgages[to][nodeId].amount = mortgages[to][nodeId].amount.add(amount);
		// use max apy to ensure `unrealisedLoans` not exceed `maxLoan`.
		if (stake.apy() > mortgages[to][nodeId].apy) {
			mortgages[to][nodeId].apy = stake.apy();
		}
	}

	function clear(address to, uint256 nodeId) external override {
		require(lendingAuthority.canMortgage(msg.sender), 'NodeLending: no auth to clear mortgage.');
		delete mortgages[to][nodeId];
		delete unrealisedLoans[to][nodeId];
	}

	function unrealise(
		address to,
		uint256 nodeId,
		uint256 amount
	) external override {
		require(nodes.exists(nodeId), 'NodeLending: nonexistent node.');
		require(nodes.ownerOf(nodeId) == address(nodes), 'NodeLending: node has been owned.');
		require(lendingAuthority.canLend(msg.sender), 'NodeLending: no auth to borrow.');
		require(realisedLoans[to][nodeId] == 0, 'NodeLending: loan not paid.');
		uint256 loan = unrealisedLoans[to][nodeId].add(amount);
		require(maxLoan(to, nodeId) >= loan, 'NodeLending: exceed max loans.');
		unrealisedLoans[to][nodeId] = loan;
	}

	function realise(address to, uint256 nodeId) external override {
		require(nodes.exists(nodeId), 'NodeLending: nonexistent node.');
		require(nodes.ownerOf(nodeId) == address(nodes), 'NodeLending: node has been owned.');
		require(lendingAuthority.canLend(msg.sender), 'NodeLending: no auth to borrow.');
		uint256 loan = unrealisedLoans[to][nodeId];
		realisedLoans[to][nodeId] = realisedLoans[to][nodeId].add(loan);
		totalNodeLoans = totalNodeLoans.add(loan);
	}

	// TODO: repayment withdrawn or direct transfer.
	function repayment(address to, uint256 nodeId) external payable override {
		uint256 loan = realisedLoans[to][nodeId];
		uint256 paid = msg.value;
		if (msg.value > loan) {
			payable(msg.sender).transfer(msg.value.sub(loan));
			paid = loan;
		}
		realisedLoans[to][nodeId] = realisedLoans[to][nodeId].sub(paid);
		totalNodeLoans = totalNodeLoans.sub(paid);
	}

	function totalLoans() external view override returns (uint256) {
		return totalNodeLoans;
	}

	function mortgageOf(address to, uint256 nodeId) external view override returns (uint256) {
		return mortgages[to][nodeId].amount;
	}

	function maxLoan(address to, uint256 nodeId) public view returns (uint256) {
		uint256 amount = mortgages[to][nodeId].amount;
		uint256 unrealisedRewardInOneYear = amount.mul(mortgages[to][nodeId].apy).div(stake.NUMERATOR());
		return unrealisedRewardInOneYear.add(amount).div(stake.RMAX()).mul(stake.NUMERATOR());
	}
}
