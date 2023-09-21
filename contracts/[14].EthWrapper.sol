// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20 {
    event deposit(address indexed account, uint256 _amount);
    event withdrawl(address indexed account, uint256 _amount);

    constructor() ERC20("Wrapped Ether", "WETH", 18) {}

    function deposit() external payable {
        _mint(msg.sender, msg.value);
        emit deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(balanceOf(msg.sender) >= amount, "Amount is invalid");
        _burn(msg.sender, amount);
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Withdraw not completed");
        emit withdrawl(msg.sender, amount);
    }

    receive() external payable {
        _mint(msg.sender, msg.value);
        emit deposit(msg.sender, msg.value);
    }

    fallback() external payable {}
}