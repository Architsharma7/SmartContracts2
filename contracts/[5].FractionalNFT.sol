// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/tree/v4.0.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/tree/v4.0.0/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/tree/v4.0.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/tree/v4.0.0/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/tree/v4.0.0/contracts/token/ERC721/utils/ERC721Holder.sol";

contract Fractions is Ownable, ERC20, ERC20Permit, ERC721Holder {
    constructor() ERC20("MyToken", "MK") ERC20Permit("MyToken") {}

    IERC721 public collection;

    // token id for nft which is to be fractionalised
    uint256 public tokenId;

    // bool to check if nft is sent to contract and the owner gets the tokens in return
    bool public initialised;
    // bool to check if the tokens can be redeemed
    bool public canRedeem;

    uint256 public price;
    bool public forSale;

    // nft is sent to sent to contract and amount of tokens are send to the owner(as much he values his nft)
    function initialise(
        address _collection,
        uint256 _tokenId,
        uint256 amount
    ) external onlyOwner {
        require(!initialised, "already initialised");
        nftcollection = IERC721(_collection);
        nftcollection.safeTransferFrom(msg.sender, address(this), _tokenId);
        tokenId = _tokenId;
        initialised = true;
        _mint(msg.sender, amount);
    }

    function putForSale(uint256 _price) external onlyOwner {
        price = _price;
        forSale = true;
    }

    function purchase() external payable {
        require(!forSale, "not for sale yet");
        require(msg.value >= price, "not enough tokens");
        nftcollection = IERC721(_collection);
        nftcollection.safeTransferFrom(address(this), msg.sender, tokenId);
        forSale = false;
        canRedeem = true;
    }

    function redeem(uint256 _amount) external payable {
        require(!canRedeem, "not able to redeem");
        uint256 etherTotal = address(this).balance;
        uint256 redeemableEther = (_amount * etherTotal) / totalSupply();
        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(redeemableEther);
        canRedeem = false;
    }
}
