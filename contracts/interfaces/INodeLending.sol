// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import './ILending.sol';

interface INodeLending is ILending {

	function mortgage(address to, uint256 nodeId, uint256 amount) external;
	
	function clear(address to, uint256 nodeId) external;

	function unrealise(address to, uint256 nodeId, uint256 amount) external;

	function realise(address to, uint256 nodeId) external;

	function mortgageEnd(address to, uint256 nodeId) external;

	function mortgageOf(address to, uint256 nodeId) external view returns (uint256);

	function unrealisedLoans(address to, uint256 nodeId) external view returns (uint256);

	function realisedLoans(address to, uint256 nodeId) external view returns (uint256);

}
