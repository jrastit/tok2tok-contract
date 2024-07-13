// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Tok2tok {
    mapping (address=>uint256) deposit;
    uint256 public total_deposit;
    uint256 public total_withdraw;
    uint256 public total_bill;
    uint256 public total_admin_withdraw;
    address public token;

    address payable owner;


    constructor (address _token) {
        token = _token;
        owner = payable(msg.sender);
    }

    event UserDepositUSDC(address indexed user, uint256 amount);

    function user_deposit_usdc (uint256 _amount) public {
        IERC20(token).transferFrom(msg.sender, address(this), _amount);
        deposit[msg.sender] += _amount;
        total_deposit += _amount;
        
        emit UserDepositUSDC(msg.sender, _amount);
    }

    event UserWithdrawUSDC(address indexed user, uint256 amount);

    function user_withdraw (uint256 _amount) public {
        require(deposit[msg.sender] >= _amount);
        total_withdraw += _amount;
        deposit[msg.sender] -= _amount;
        IERC20(token).transfer(msg.sender, _amount);
        emit UserWithdrawUSDC(msg.sender, _amount);
    }

    function withdraw_all () public {
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

    function admin_withdraw_usdc(address payable to, uint256 amount) public {
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

}
