// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import './interfaces/IStakeReward.sol';
import './interfaces/ILending.sol';
import './interfaces/IParams.sol';

contract Stake is Ownable {
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

	IStakeReward public immutable reward;

	IParams public immutable params;

	constructor(address owner, IParams params_, ILending lending_, IStakeReward reward_) {
		transferOwnership(owner);
		params = params_;
		reward = reward_;
		lending = lending_;
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

	function apy() public view returns (uint256) {
		return U().mul(m()).add(b()).div(numerator());
	}

	function U() public view returns (uint256) {
		if (totalDeposits == 0 || totalLoans() == 0) {
			return 0;
		}
		return totalLoans().mul(numerator()).div(totalDeposits);
	}

	function m() public view returns (uint256) {
		uint256 u = U();
		if (u < numerator().mul(5)) {
			return uint256(4).mul(numerator()).div(10);
		} else if (u < numerator().mul(9)) {
			return 0;
		} else {
			uint256 dot1 = numerator().div(10);
			uint256 dot2 = dot1.mul(2);
			return rmax().sub(dot2).div(dot1);
		}
	}

	function b() public view returns (uint256) {
		uint256 u = U();
		if (u < numerator().mul(5)) {
			return 0;
		} else if (u < numerator().mul(9)) {
			return uint256(2).mul(numerator()).div(10);
		} else {
			return m().sub(rmax());
		}
	}

	function unrealisedReward(address to) public view returns (uint256 amount) {
		require(deposits[to].lastUpdateTime != 0, 'AuctionLending: invalid deposit time.');
		require(block.timestamp > deposits[to].lastUpdateTime, 'AuctionLending: past block.');
		uint256 interval = block.timestamp.sub(deposits[to].lastUpdateTime);
		amount = deposits[to].amount.mul(apy()).mul(interval).div(numerator()).div(365 days);
	}

	function availableReward(address to) public view returns (uint256) {
		return reward.realised(to).add(unrealisedReward(to));
	}

	function totalLoans() public view returns (uint256) {
		return lending.totalLoans();
	}

	function numerator() public view returns (uint256) {
		return params.NUMERATOR();
	}

	function rmax() public view returns (uint256) {
		return params.RMAX();
	}

	modifier hasDeposit() {
		require(deposits[msg.sender].lastUpdateTime != 0 && deposits[msg.sender].amount != 0, 'AuctionLending: no deposit.');
		_;
	}

	function _mintReward(address to) internal {
		reward.mint(to, unrealisedReward(to));
	}
}
