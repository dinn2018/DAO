// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import './access/NodeAuthority.sol';
import './access/LendingAuthority.sol';

import './NodeController.sol';

contract Controller is NodeController, NodeAuthority, LendingAuthority {

	constructor(address newOwner) {
		transferOwnership(newOwner);
	}

}