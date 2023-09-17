//SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import {
    ISuperfluid, 
    ISuperToken, 
    ISuperApp
} from "@superfluid-finance/ethereum-contracts/contracts/interfaces/superfluid/ISuperfluid.sol";

import { SuperTokenV1Library } from "@superfluid-finance/ethereum-contracts/contracts/apps/SuperTokenV1Library.sol";

error Unauthorized();

// You can call 'createFlowIntoContract' to create a stream into the contract. But before you do this you must grant the contract an approval to create streams on your behalf with the Superfluid access control list. More on this here: https://docs.superfluid.finance/superfluid/developers/constant-flow-agreement-cfa/cfa-access-control-list-acl/acl-features

contract Streaming {

    address public owner;
    using SuperTokenV1Library for ISuperToken;

    // Allow list.
    mapping(address => bool) public accountList;

    constructor(address _owner) {
        owner = _owner;
    }

    /// Add account to allow list.
    function allowAccount(address _account) external {
        if (msg.sender != owner) revert Unauthorized();

        accountList[_account] = true;
    }

    /// Removes account from allow list.
    function removeAccount(address _account) external {
        if (msg.sender != owner) revert Unauthorized();

        accountList[_account] = false;
    }

    function changeOwner(address _newOwner) external {
        if (msg.sender != owner) revert Unauthorized();

        owner = _newOwner;
    }

    /// Send a lump sum of super tokens into the contract.
    function sendLumpSumToContract(ISuperToken token, uint256 amount) external {
        if (!accountList[msg.sender] && msg.sender != owner) revert Unauthorized();

        token.transferFrom(msg.sender, address(this), amount);
    }

    /// Create a stream into the contract.
    function createFlowIntoContract(ISuperToken token, int96 flowRate) external {
        if (!accountList[msg.sender] && msg.sender != owner) revert Unauthorized();

        token.createFlowFrom(msg.sender, address(this), flowRate);
    }

    /// Update an existing stream being sent into the contract by msg sender.
    function updateFlowIntoContract(ISuperToken token, int96 flowRate) external {
        if (!accountList[msg.sender] && msg.sender != owner) revert Unauthorized();

        token.updateFlowFrom(msg.sender, address(this), flowRate);
    }

    /// Delete a stream that the msg.sender has open into the contract.
    function deleteFlowIntoContract(ISuperToken token) external {
        if (!accountList[msg.sender] && msg.sender != owner) revert Unauthorized();

        token.deleteFlow(msg.sender, address(this));
    }

    /// Withdraw funds from the contract.
    function withdrawFunds(ISuperToken token, uint256 amount) external {
        if (!accountList[msg.sender] && msg.sender != owner) revert Unauthorized();

        token.transfer(msg.sender, amount);
    }

    /// Create flow from contract to specified address.
    function createFlowFromContract(
        ISuperToken token,
        address receiver,
        int96 flowRate
    ) external {
        if (!accountList[msg.sender] && msg.sender != owner) revert Unauthorized();

        token.createFlow(receiver, flowRate);
    }

    /// Update flow from contract to specified address.
    function updateFlowFromContract(
        ISuperToken token,
        address receiver,
        int96 flowRate
    ) external {
        if (!accountList[msg.sender] && msg.sender != owner) revert Unauthorized();

        token.updateFlow(receiver, flowRate);
    }

    /// Delete flow from contract to specified address.
    function deleteFlowFromContract(ISuperToken token, address receiver) external {
        if (!accountList[msg.sender] && msg.sender != owner) revert Unauthorized();

        token.deleteFlow(address(this), receiver);
    }
}