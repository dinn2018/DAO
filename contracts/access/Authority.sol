// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import '@openzeppelin/contracts/utils/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

import '../interfaces/IAuthority.sol';

abstract contract Authority is Ownable, IAuthority {
	using SafeMath for uint256;

	mapping(address => uint256) public allAuth;

	event Enable(address indexed to, uint256 auth);

	function enable(address to, uint256 auth) external override onlyOwner {
		allAuth[to] = auth;
		emit Enable(to, auth);
	}

	/// @param to authority owner.
	/// @param level authority level.
	/// 0 add node.
	/// 1 remove node.
	/// 2 transfer node.
	/// 3 punish node.
	/// @return whether `to` satisfies `level` authority.
	function can(address to, uint8 level) public view override returns (bool) {
		return (allAuth[to] & (1 << level)) > 0;
	}
}
