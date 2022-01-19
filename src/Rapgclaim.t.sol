// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./Rapgclaim.sol";

contract RapgclaimTest is DSTest {
    Rapgclaim rapgclaim;

    function setUp() public {
        rapgclaim = new Rapgclaim();
    }
}
