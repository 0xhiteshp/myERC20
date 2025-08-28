// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.4.0
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract myERC is ERC20, Ownable {
    constructor(address recipient, address initialOwner) ERC20("myERC", "SJ") Ownable(initialOwner) {
        _mint(recipient, 100000 * 10 ** decimals());
    }
}
