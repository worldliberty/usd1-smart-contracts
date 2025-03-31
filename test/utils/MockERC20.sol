// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../../src/Stablecoin.sol";

contract MockERC20 is Stablecoin {
    constructor() {
        initialize("Mock Token", "MOCK");
    }
}
