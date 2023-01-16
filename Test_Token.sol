// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./ERC20.sol";

contract Test_Token is ERC20 {
    constructor() ERC20("TestToken", "TT") {}

    function mint() public {
        _mint(_msgSender(), 10 ether);
    }
}
