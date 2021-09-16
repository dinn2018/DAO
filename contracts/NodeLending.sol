// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import './interfaces/INodeLending.sol';

contract NodeLending is INodeLending, Ownable {
	using SafeMath for uint256;

	mapping(uint256 => uint256) public loans;

	mapping(address => bool) public delegators;

	uint256 private totalNodeLoans;

	constructor(address controller) {
		transferOwnership(controller);
	}

	function approve(address delegator, bool approval) external onlyOwner {
		delegators[delegator] = approval;
	}

	function borrow(uint256 nodeId, uint256 loan) external override onlyDelegator {
		loans[nodeId] = loans[nodeId].add(loan);
		totalNodeLoans = totalNodeLoans.add(loan);
	}

	// TODO: repayment withdrawn or direct transfer.
	function repayment(uint256 nodeId) external payable override {
		uint256 loan = loans[nodeId];
		uint256 paid = msg.value;
		if (msg.value > loan) {
			payable(msg.sender).transfer(msg.value.sub(loan));
			paid = loan;
		}
		loans[nodeId] = loans[nodeId].sub(paid);
		totalNodeLoans = totalNodeLoans.sub(paid);
	}

	function totalLoans() external view override returns (uint256) {
		return totalNodeLoans;
	}

	modifier onlyDelegator() {
		require(delegators[msg.sender], 'Lending: not a delegator.');
		_;
	}
}
