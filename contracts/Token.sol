// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract Token is ERC20, ERC20Permit {
    constructor() ERC20("Test USD", "TUSD") ERC20Permit("Test USD") {}

    function faucet(address addr) external {
        _mint(addr, 10**24);
    }
}
