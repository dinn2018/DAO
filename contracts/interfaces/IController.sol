// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import './ILendingAuthority.sol';
import './INodeAuthority.sol';
import './IParams.sol';

interface IController is INodeAuthority, ILendingAuthority, IParams {

}
