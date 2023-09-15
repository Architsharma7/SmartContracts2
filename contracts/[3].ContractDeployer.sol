// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract AccountFactory {

    Account[] public _deployed;

    function createAccount(uint _b) public {
        Account account  = new Account(_b, msg.sender);
        // can be done like this also
        // Account account = new Account{value: 0}(_b, msg.sender); // 0 is the ether we are sending to this contract
        // remember : @dev : here the msg.sender will be the deployer contract and not the eoa
        _deployed.push(account);
    }
}

contract Account {
    address public owner;
    uint256 public b;

    constructor(uint256 _b, address _owner) {
        owner = _owner;
        b = _b;
    }

    function seeOwner() public view returns(address) {
        return owner;
    }
}
