// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import './interfaces/IParams.sol';

abstract contract Params is Ownable, IParams { 

	uint256 public override perSecReward = 1e16;

	uint256 public override RMAX = 15e11;

	uint256 public override NUMERATOR = 1e12;

	function setPerSecReward(uint256 perSecReward_) external onlyOwner {
		perSecReward = perSecReward_;
	}

}