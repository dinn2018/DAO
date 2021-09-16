// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface IStakeReward {
	function realised(address to) external view returns (uint256);

	function withdraw(address payable to, uint256 amount) external;

	function mint(address to, uint256 amount) external;
}
