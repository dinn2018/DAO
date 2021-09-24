// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface IParams  { 

	function RMAX() external view returns (uint256);

	function RDECIMALS() external view returns (uint256);

	function perSecReward() external view returns (uint256);

}