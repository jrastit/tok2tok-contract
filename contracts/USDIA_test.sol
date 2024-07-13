// SPDX-License-Identifier: MIT 

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDIA_test is ERC20 {
    constructor() ERC20("USDIA", "USDIA test") {
        _mint(msg.sender, 1000000000000000000000000);
    }
    
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}