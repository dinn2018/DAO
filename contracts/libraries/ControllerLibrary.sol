// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import '../interfaces/IController.sol';

library ControllerLibrary {
	function safeLockTime(IController controller) internal view returns (uint256) {
		(bool success, bytes memory data) = address(controller).staticcall(abi.encodeWithSelector(controller.lockTime.selector));
		require(success, 'ControllerLibrary: failed to call `safeLockTime`');
		return abi.decode(data, (uint256));
	}
}
