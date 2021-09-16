// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface IStake {
	function NUMERATOR() external view returns (uint256);

	function RMAX() external view returns (uint256);

	function apy() external view returns (uint256);
}
