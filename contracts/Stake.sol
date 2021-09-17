// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import './interfaces/IStakeReward.sol';
import './interfaces/IStake.sol';
import './interfaces/ILending.sol';

contract Stake is IStake, Ownable {
	using SafeMath for uint256;

	struct Deposit {
		uint256 amount;
		uint256 lastUpdateTime;
	}

	struct Mortgage {
		uint256 amount;
		uint256 apy;
	}

	mapping(address => Deposit) public deposits;

	mapping(address => uint256) public loans;

	uint256 public totalDeposits;

	ILending public lending;

	uint256 public immutable override NUMERATOR = 1e12;

	uint256 public immutable override RMAX = 15 * 1e12;

	IStakeReward public immutable reward;

	constructor(address owner, IStakeReward reward_) {
		transferOwnership(owner);
		reward = reward_;
	}

	function setLending(ILending lending_) external onlyOwner {
		if (address(lending) == address(0)) {
			lending = lending_;
		}
	}

	function deposit() external payable {
		address to = msg.sender;
		uint256 lastUpdateTime = deposits[to].lastUpdateTime;
		if (lastUpdateTime != 0) {
			_mintReward(to);
		}
		deposits[to].amount = deposits[to].amount.add(msg.value);
		deposits[to].lastUpdateTime = block.timestamp;
		totalDeposits = totalDeposits.add(msg.value);
	}

	function withdrawDeposit(uint256 amount) public hasDeposit {
		address to = msg.sender;
		require(deposits[to].amount >= amount, 'FourEverAuctionLending: not enough deposit to withdraw.');
		_mintReward(to);
		deposits[to].amount = deposits[to].amount.sub(amount);
		deposits[to].lastUpdateTime = block.timestamp;
		totalDeposits = totalDeposits.sub(amount);

		payable(to).transfer(amount);
	}

	function withdrawReward(uint256 amount) public {
		reward.withdraw(payable(msg.sender), amount);
	}

	function withdrawDepositAndReward() external hasDeposit {
		address to = msg.sender;
		withdrawDeposit(deposits[to].amount);
		withdrawReward(reward.realised(to));
	}

	function apy() public view override returns (uint256) {
		return U().mul(m()).add(b()).div(NUMERATOR);
	}

	function U() public view returns (uint256) {
		if (totalDeposits == 0 || totalLoans() == 0) {
			return 0;
		}
		return totalLoans().mul(NUMERATOR).div(totalDeposits);
	}

	function m() public view returns (uint256) {
		uint256 u = U();
		if (u < NUMERATOR.mul(5)) {
			return uint256(4).mul(NUMERATOR).div(10);
		} else if (u < NUMERATOR.mul(9)) {
			return 0;
		} else {
			uint256 dot1 = NUMERATOR.div(10);
			uint256 dot2 = dot1.mul(2);
			return RMAX.sub(dot2).div(dot1);
		}
	}

	function b() public view returns (uint256) {
		uint256 u = U();
		if (u < NUMERATOR.mul(5)) {
			return 0;
		} else if (u < NUMERATOR.mul(9)) {
			return uint256(2).mul(NUMERATOR).div(10);
		} else {
			return m().sub(RMAX);
		}
	}

	function unrealisedReward(address to) public view returns (uint256 amount) {
		require(deposits[to].lastUpdateTime != 0, 'AuctionLending: invalid deposit time.');
		require(block.timestamp > deposits[to].lastUpdateTime, 'AuctionLending: past block.');
		uint256 interval = block.timestamp.sub(deposits[to].lastUpdateTime);
		amount = deposits[to].amount.mul(apy()).mul(interval).div(NUMERATOR).div(365 days);
	}

	function availableReward(address to) public view returns (uint256) {
		return reward.realised(to).add(unrealisedReward(to));
	}

	function totalLoans() public view returns (uint256) {
		return lending.totalLoans();
	}

	modifier hasDeposit() {
		require(deposits[msg.sender].lastUpdateTime != 0 && deposits[msg.sender].amount != 0, 'AuctionLending: no deposit.');
		_;
	}

	function _mintReward(address to) internal {
		reward.mint(to, unrealisedReward(to));
	}
}
