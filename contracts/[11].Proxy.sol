//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// First deploy the logic contract (MyContract). Then deploy the Proxy contract. In the arguments for Proxy contract's constructor, send the calldata and address of MyContract. To compute the calldata, run this in the remix console -
// web3.utils.sha3('initialize()').substr(0, 10)
// If the initialization function is different for your contract, change the initialize() to your contract's function name. initilizaton function is just the constructor for proxy contract, bc it can't have a constuctor.

contract Proxy {
    // Code position in storage is keccak256("PROXIABLE") = "0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7"
    constructor(bytes memory constructData, address contractLogic) {
        // save the code address
        assembly {
            // solium-disable-line
            sstore(
                0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7,
                contractLogic
            )
        }
        (bool success, bytes memory result) = contractLogic.delegatecall(
            constructData
        ); // solium-disable-line
        require(success, "Construction failed");
    }

    fallback() external payable {
        assembly {
            // solium-disable-line
            let contractLogic := sload(
                0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7
            )
            calldatacopy(0x0, 0x0, calldatasize())
            let success := delegatecall(
                sub(gas(), 10000),
                contractLogic,
                0x0,
                calldatasize(),
                0,
                0
            )
            let retSz := returndatasize()
            returndatacopy(0, 0, retSz)
            switch success
            case 0 {
                revert(0, retSz)
            }
            default {
                return(0, retSz)
            }
        }
    }
}

// this contract is used just to make the contract proxiable.

contract Proxiable {
    // Code position in storage is keccak256("PROXIABLE") = "0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7"

    function updateCodeAddress(address newAddress) internal {
        require(
            bytes32(
                0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7
            ) == Proxiable(newAddress).proxiableUUID(),
            "Not compatible"
        );
        assembly {
            // solium-disable-line
            sstore(
                0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7,
                newAddress
            )
        }
    }

    function proxiableUUID() public pure returns (bytes32) {
        return
            0xc5f16f0fcc639fa48a6947836d9850f504798523bf8c9a3a87d5876cf622bcf7;
    }
}

// always list the state varibales of the new contract in the same order of the original contract i.e MyContract here.

contract MyContract is Proxiable {
    address public owner;
    uint public count;
    bool public initalized = false;

    function initialize() public {
        require(owner == address(0), "Already initalized");
        require(!initalized, "Already initalized");
        owner = msg.sender;
        initalized = true;
    }

    function increment() public {
        count++;
    }

    function updateCode(address newCode) public onlyOwner {
        updateCodeAddress(newCode);
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only owner is allowed to perform this action"
        );
        _;
    }
}
