// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// The gas fees for minting are rolled into the same transaction that assigns the NFT to the buyer, so the NFT creator never has to pay to mint.
// Minting "just in time" at the moment of purchase.

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";

contract LazyMinting is ERC721, ERC721URIStorage, Ownable, EIP712 {
    string private constant SIGNING_DOMAIN = "Voucher-Domain";
    string private constant SIGNATURE_DOMAIN = "1";

    constructor()
        ERC721("LazyMinting", "LZ")
        EIP712(SIGNING_DOMAIN, SIGNATURE_DOMAIN)
    {}

    struct LazyNFTVoucher {
        uint256 price;
        uint256 tokenId;
        string uri;
        address buyer;
        bytes signature;
    }

    function recover(
        LazyNFTVoucher calldata voucher
    ) public view returns (address) {
        bytes32 digest = _hashTypedDataV4(
            keccak256(
                abi.encode(
                    keccak256(
                        "LazyNFTVoucher(uint256 tokenId,uint256 price,string uri,address buyer)"
                    ),
                    voucher.tokenId,
                    voucher.price,
                    keccak256(bytes(voucher.uri)),
                    voucher.buyer
                )
            )
        );
        address signer = ECDSA.recover(digest, voucher.signature);
        return signer;
    }

    function safeMint(
      LazyNFTVoucher calldata voucher 
    ) public {
        require(owner() == recover(voucher));
        require(msg.value >= voucher.price);
        _safeMint(voucher.buyer, voucher.tokenId);
        _setTokenURI(voucher.tokenId, voucher.uri);
    }

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}
