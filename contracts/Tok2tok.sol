// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Tok2tok {
    mapping (address=>uint256) deposit;
    uint256 public total_deposit;
    uint256 public total_withdraw;
    uint256 public total_bill;
    uint256 public total_admin_withdraw;

    address payable owner;

    constructor () {
        owner = payable(msg.sender);
    }

    event UserDeposit(address indexed user, uint256 amount);

    function user_deposit () public payable {
        deposit[msg.sender] += msg.value;
        total_deposit += msg.value;
        emit UserDeposit(msg.sender, msg.value);
    }

    event UserWithdraw(address indexed user, uint256 amount);

    function user_withdraw (uint256 amount) public {
        require(deposit[msg.sender] >= amount);
        total_withdraw += amount;
        deposit[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit UserWithdraw(msg.sender, amount);
    }

    function withdraw_all () public {
        uint256 amount = deposit[msg.sender];
        total_withdraw += amount;
        deposit[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit UserWithdraw(msg.sender, amount);
    }

    event BillUser(address indexed user, uint256 amount);
    
    function bill_user (uint256 amount) public {
        uint256 balance = user_balance();
        if (balance < amount) {
            amount = balance;
        }
        require(msg.sender == owner);
        total_bill += amount;
        deposit[msg.sender] += amount;
        emit BillUser(msg.sender, amount);
    }

    function admin_withdraw (address payable to, uint256 amount) public {
        require(msg.sender == owner);
        require(amount <= total_bill - total_admin_withdraw);
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
        return address(this).balance;
    }

    function contract_owner () public view returns (address) {
        return owner;
    }

}
