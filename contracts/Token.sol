// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract Token is Initializable, ERC20Upgradeable, ERC20PermitUpgradeable, OwnableUpgradeable {
    function initialize() initializer public {
        __ERC20_init("Test USD", "TUSD");
        __ERC20Permit_init("Test USD");
    }

    function faucet(address addr) external {
        _mint(addr, 10**20);
    }
}
