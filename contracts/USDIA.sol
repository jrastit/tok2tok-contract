// SPDX-License-Identifier: MIT 

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDIA is ERC20 {
    constructor() ERC20("USDIA", "USDIA") {
        _mint(msg.sender, 1000000000000000000000000);
    }
}