// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import './Authority.sol';
import '../interfaces/INodeAuthority.sol';

contract NodeAuthority is Authority, INodeAuthority {
	function canAddNode(address to) external view override returns (bool) {
		return can(to, 0);
	}

	function canRemoveNode(address to) external view override returns (bool) {
		return can(to, 10);
	}

	function canMortgageNode(address to) external view override returns (bool) {
		return can(to, 20);
	}

	function canPunishNode(address to) external view override returns (bool) {
		return can(to, 30);
	}

	function canExitNode(address to) external view override returns (bool) {
		return can(to, 40);
	}

}
