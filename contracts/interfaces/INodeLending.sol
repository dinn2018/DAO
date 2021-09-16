// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import './ILending.sol';

interface INodeLending is ILending {

	function borrow(uint256 nodeId, uint256 loan) external;

	function repayment(uint256 nodeId) external payable;

}
