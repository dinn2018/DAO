// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import './interfaces/IStakeReward.sol';

contract StakeReward is IStakeReward, Ownable {

	using SafeMath for uint256;

	address public minter;

	mapping(address => uint256) public override realised;

	function transferMinter(address minter_) external onlyOwner {
		minter = minter_;
	}

	function popReward(address payable to, uint256 amount) external onlyOwner {
		to.transfer(amount);
	}

	function mint(address to, uint256 amount) external override onlyMinter{
		realised[to] = realised[to].add(amount);
	}

	function withdraw(address payable to, uint256 amount) external override onlyMinter {
		require(realised[to] >= amount, 'Reward: not enough reward for withdrawal.');
		realised[to] = realised[to].sub(amount);
		to.transfer(amount);
	}

	modifier onlyMinter() {
		require(msg.sender == minter, 'Reward: incorrect minter.');
		_;
	}
}
