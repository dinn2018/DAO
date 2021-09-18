// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import './IAuthority.sol';

interface ILendingAuthority is IAuthority {

	function canLend(address to) external view returns (bool);

}
