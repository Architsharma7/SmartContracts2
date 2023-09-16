// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/tree/v4.0.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/tree/v4.0.0/contracts/token/ERC721/utils/ERC721Holder.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/tree/v4.0.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/tree/v4.0.0/contracts/token/ERC721/IERC721.sol";

contract NFTStaking is Ownable, ERC20, ERC721Holder {
    IERC721 public nft;

    constructor(address _nft) ERC20("MyToken", "MT") {
        nft = IERC721(_nft);
    }

    mapping(uint256 => address) public tokenOwnerOf;
    mapping(uint256 => uint256) public tokenStakedAt;

    uint public Emission_Rate = ((50 * 10) ^ decimals()) / 1 days;

    function stake(uint256 _tokenId) external {
        nft.safeTransferFrom(msg.sender, address(this), _tokenId);
        tokenOwnerOf[_tokenId] = msg.sender;
        tokenStakedAt[_tokenId] = block.timestamp;
    }

    function calculateTokens(uint256 _tokenId) public view returns (uint256) {
        uint256 timeElapsed = (block.timestamp - tokenStakedAt[_tokenId]);
        return timeElapsed * Emission_Rate;
    }

    function unstake(uint256 _tokenId) external {
        require(tokenOwnerOf[_tokenId] == msg.sender, "not owner of nft");
        _mint(msg.sender, calculateTokens(_tokenId)); // mint tokens to the owner
        nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        delete tokenOwnerOf[_tokenId];
        delete tokenStakedAt[_tokenId];
    }
}
