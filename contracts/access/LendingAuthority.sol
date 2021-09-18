// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import './Authority.sol';
import '../interfaces/ILendingAuthority.sol';

contract LendingAuthority is Authority, ILendingAuthority {
	function canLend(address to) external view override returns (bool) {
		return can(to, 60);
	}
}
