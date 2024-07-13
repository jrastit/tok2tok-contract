// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Tok2tok {
    mapping (address=>uint256) deposit;
    mapping (address=>uint256) lock;

    uint256 public total_deposit;
    uint256 public total_withdraw;
    uint256 public total_bill;
    uint256 public total_admin_withdraw;
    address public token;

    address payable owner;

    constructor (_token) {
        token = _token;
        owner = payable(msg.sender);
    }

    event UserDepositUSDC(address indexed user, uint256 amount);

    function user_deposit_usdc (uint256 _amount) public {
        IERC20(token).transferFrom(msg.sender, address(this), _amount);
        deposit[msg.sender] += msg.value;
        total_deposit += msg.value;
        
        emit UserDepositUSDC(msg.sender, amount);
    }

    function user_lock () public {
        lock[msg.sender] = block.timestamp;
    }

    event UserWithdrawUSDC(address indexed user, uint256 amount);

    function user_withdraw (uint256 amount) public {
        require(deposit[msg.sender] >= amount, "Insufficient balance");
        require(block.timestamp - lock[msg.sender] > 1 minutes, "Withdrawal locked");
        require(block.timestamp - lock[msg.sender] < 1 hours, "Withdrawal locked");
        
        lock[msg.sender] = 0;
        total_withdraw += amount;
        deposit[msg.sender] -= amount;
        IERC20(token).transfer(msg.sender, amount);
        emit UserWithdrawUSDC(msg.sender, amount);
    }

    function withdraw_all () public {
        require(block.timestamp - lock[msg.sender] > 1 minutes, "Withdrawal locked");
        require(block.timestamp - lock[msg.sender] < 1 hours, "Withdrawal locked");
        
        uint256 amount = deposit[msg.sender];
        total_withdraw += amount;
        deposit[msg.sender] = 0;
        IERC20(token).transfer(msg.sender, amount);
        emit UserWithdrawUSDC(msg.sender, amount);
    }

    event BillUser(address indexed user, uint256 amount);
    
    function bill_user (uint256 amount) public {
        uint256 balance = user_balance();
        if (balance < amount) {
            amount = balance;
        }
        require(msg.sender == owner);
        total_bill += amount;
        deposit[msg.sender] -= amount;
        emit BillUser(msg.sender, amount);
    }

    function admin_withdraw_usdc(address payable to, amount) public {
        require(msg.sender == owner);
        require(amount <= total_bill - total_admin_withdraw);
        IERC20(token).transfer(to, amount);
    }

    function admin_withdraw (address payable to, uint256 amount) public {
        require(msg.sender == owner);
        total_admin_withdraw += amount;
        to.transfer(amount);
    }

    function admin_balance () public view returns (uint256) {
        return total_bill - total_admin_withdraw;
    }

    function user_balance () public view returns (uint256) {
        return deposit[msg.sender];
    }

    function contract_balance () public view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function contract_owner () public view returns (address) {
        return owner;
    }

    function user_has_token () public view returns (bool) {
        require (lock[msg.sender] == 0 || block.timestamp - lock[msg.sender] > 1 hours);
        return deposit[msg.sender] > 0;
    }

}
