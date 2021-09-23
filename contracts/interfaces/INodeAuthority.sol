// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import './IAuthority.sol';

interface INodeAuthority is IAuthority{

	function canAddNode(address to) external view returns (bool);

	function canRemoveNode(address to) external view returns (bool);

	function canMortgageNode(address to) external view returns (bool);

	function canPunishNode(address to) external view returns (bool);

	function canExitNode(address to) external view returns (bool);

}
