// SPDX-License-Identifier: MIT 

pragma solidity >=0.7.0 <0.9.0;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDIA is ERC20 {
    constructor() ERC20("USDIA", "USDIA") {
        _mint(msg.sender, 1000000000000000000000000);
    }
}