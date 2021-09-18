// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface IParams  { 

	function RMAX() external view returns (uint256);

	function NUMERATOR() external view returns (uint256);

	function perblockReward() external view returns (uint256);

}