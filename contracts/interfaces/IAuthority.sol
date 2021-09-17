// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

interface IAuthority {
	function enable(address to, uint256 auth) external;

	/// @param to authority owner.
	/// @param level authority level.
	/// @return whether `to` satisfies `level` authority.
	function can(address to, uint8 level) external view returns (bool);
}
