// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import './interfaces/IController.sol';

contract Controller is IController {

	uint256 public override lockTime;

	function setLockTime(uint256 lockTime_) external {
		lockTime = lockTime_;
	}

}
