// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

import './Authority.sol';
import '../interfaces/ILendingAuthority.sol';

contract LendingAuthority is Authority, ILendingAuthority {
	function canBorrow(address to) external view override returns (bool) {
		return can(to, 4);
	}

	function canMortgage(address to) external view override returns (bool) {
		return can(to, 5);
	}

}
