// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/access/Ownable.sol";

contract SplitPay is Ownable {
    address[] public payers;
    uint public totalPayers;
    uint256 public totalRequests;

    event Paid(address indexed payee, uint256 amount);
    event PaidForRequest(uint256 _reqId, address payer, uint256 amountPaid);
    event Recieved(address _payer, uint256 _amountAdded);

    struct payRequest {
        uint totalAmount;
        address payee;
        address[] paid;
    }

    mapping(uint256 => payRequest) public payments;

    constructor(address _payers, uint256 _NoOfPayers) payable {
        payers = _payers;
        totalPayers = _NoOfPayers;
    }

    function pay(address _payee, uint _amount) external {
        require(_amount > address(this).balance, "not allowed");
        require(_payee != address(0), "Invalid address");

        PayRequest memory _request = payments[totalRequests];
        _request.payee = _payee;
        _request.totalAmount = _amount;

        (bool success, ) = _payee.call{value: _amount}("");
        require(success, "request not completed");

        emit Paid(_payee, _amount);
    }

    function payForRequest(uint256 _reqId) public payable {
        PayRequest memory _request = payments[_reqId];
        uint256 amountPer = (_request.totalAmount) / totalPayers;
        require(msg.value >= amountPer, "Wrong amount sent ");

        _request.payee.push(msg.sender);
        emit PaidForRequest(_reqId, msg.sender, msg.value);
    }

    receive() external payable {
        emit Recieved(msg.sender, msg.value);
    }

    fallback() external payable {}
}
