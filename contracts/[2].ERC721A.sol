// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "./Ownable.sol";

// allow for gas-efficient minting of multiple NFTs in one transaction.

contract BatchNFTs is Ownable, ERC721A {
    uint256 public constant MAX_SUPPLY;
    uint256 public constant PRICE_PER_TOKEN;
    bool public mint_paused;
    uint256 private baseTokenUri;

    constructor(uint256 maxsupply, uint256 pricepertoken, bool mintpaused) {
        MAX_SUPPLY = maxsupply;
        PRICE_PER_TOKEN = pricepertoken;
        mint_paused = mintpaused;
    }

    function mint(address to, uint256 quantity) external payable {
        require(!mint_paused, "cannot mint now");
        require(_totalMinted() + quantity <= MAX_SUPPLY, "exceeded supply");
        require(msg.value >= quantity * PRICE_PER_TOKEN, "not enought ethers");
        _mint(to, quantity);
    }

    function withdraw() external onlyOwner {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "transaction failed");
    }

    function pause_mint(bool pause_unpause) external onlyOwner {
        require(!mintPaused, "Contract paused.");
        mint_paused = pause_unpause;
    }

    function setBaseTokenURI(uint256 _baseTokenUri) external onlyOwner {
        baseTokenUri = _baseTokenUri;
    }
}
