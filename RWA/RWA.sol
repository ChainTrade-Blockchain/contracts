// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.27;

import {ERC1363} from "@openzeppelin/contracts/token/ERC20/extensions/ERC1363.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Allowlist} from "@openzeppelin/community-contracts/token/ERC20/extensions/ERC20Allowlist.sol";
import {ERC20Bridgeable} from "@openzeppelin/community-contracts/token/ERC20/extensions/ERC20Bridgeable.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20Custodian} from "@openzeppelin/community-contracts/token/ERC20/extensions/ERC20Custodian.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MyRWA is ERC20, ERC20Bridgeable, ERC20Burnable, Ownable, ERC1363, ERC20Permit, ERC20Custodian, ERC20Allowlist {
    address public immutable TOKEN_BRIDGE;
    error Unauthorized();

    constructor(address tokenBridge, address initialOwner)
        ERC20("MyRWA", "RWA")
        Ownable(initialOwner)
        ERC20Permit("MyRWA")
    {
        require(tokenBridge != address(0), "Invalid TOKEN_BRIDGE address");
        TOKEN_BRIDGE = tokenBridge;
    }

    function _checkTokenBridge(address caller) internal view override {
        if (caller != TOKEN_BRIDGE) revert Unauthorized();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function _isCustodian(address user) internal view override returns (bool) {
        return user == owner();
    }

    function allowUser(address user) public onlyOwner {
        _allowUser(user);
    }

    function disallowUser(address user) public onlyOwner {
        _disallowUser(user);
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Custodian, ERC20Allowlist)
    {
        super._update(from, to, value);
    }

    function _approve(address owner, address spender, uint256 value, bool emitEvent)
        internal
        override(ERC20, ERC20Allowlist)
    {
        super._approve(owner, spender, value, emitEvent);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC20Bridgeable, ERC1363)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}