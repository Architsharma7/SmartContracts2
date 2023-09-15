// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract AcessControl {
    mapping(bytes32 => mapping(address => bool)) roles;

    event GrantRole(bytes32 indexed role, address indexed account);
    event RevokeRole(bytes32 indexed role, address indexed account);

    bytes32 private constant ADMIN = keccak256(abi.encodePacked("ADMIN"));
    bytes32 private constant USER = keccak256(abi.encodePacked("USER"));
    bytes32 private constant MODERATOR =
        keccak256(abi.encodePacked("MODERATOR"));

    constructor() {
        _grantRole(ADMIN, msg.sender);
    }

    function _grantRole(bytes32 _role, address _account) internal {
        roles[_role][_account] = true;
        emit GrantRole(_role, _account);
    }

    function revokeRole(bytes32 _role, address _account) internal {
        roles[_role][_account] = false;
        emit RevokeRole(_role, _account);
    }

    modifier onlyAdmin {
        require(roles[ADMIN][msg.sender] == true, "Not authorised");
        _;
    }

    modifier onlyRole(bytes32 _role){
        require(roles[_role][msg.sender], "Not authorised");
        _;
    }

    function grantRole(bytes32 _role, address _account) external onlyAdmin {
        _grantRole(_role, _account);
    }
}
