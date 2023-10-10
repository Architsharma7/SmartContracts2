// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../interfaces/AutomateReady.sol";

contract dynNFT is ERC721, ERC721URIStorage, Ownable, AutomateReady {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    
    string[] IpfsUri = [
        "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/seed.json",
        "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/purple-sprout.json",
        "https://ipfs.io/ipfs/QmYaTsyxTDnrG4toc8721w62rL4ZBKXQTGj9c9Rpdrntou/purple-blooms.json"
    ];

    uint256 lastTimeStamp;
    uint256 interval;

    constructor(
        uint256 _interval,
        address _automate,
        address _taskCreator
    ) ERC721("dNFTs", "dNFT") AutomateReady(_automate, _taskCreator) {
        interval = _interval;
        lastTimeStamp = block.timestamp;
    }

function _resolverModuleArg(address _resolverAddress, bytes memory _resolverData) public pure returns (bytes memory) {
    return _resolverData;
}

    function _createTask(
        address execAddress,
        bytes memory execDataOrSelector,
        ModuleData memory moduleData,
        address feeToken
    ) internal returns (bytes32 taskId) {
        moduleData = ModuleData({
            modules: new Module[](1),
            args: new bytes[](1)
        });
        moduleData.modules[0] = Module.RESOLVER;
        moduleData.args[0] = _resolverModuleArg(
            address(this),
            abi.encodeCall(this.checker, ())
        );
        execAddress = address(this);
        execDataOrSelector = abi.encodeCall(this.exec, ());
        feeToken = address(0);

        taskId = _createTask(
            address(this),
            abi.encodeCall(this.exec,()),
            moduleData,
            address(0)
        );
    }

    function checker()
        external
        view
        returns (bool canExec, bytes memory execData)
    {
        canExec = (block.timestamp - lastTimeStamp) > interval;
        if (canExec) {
            execData = abi.encodeCall(this.exec, ());
        }
        return (canExec, execData);
    }

    // need to pay gas from chainlink automation dashboard
    function exec() external {
        require((block.timestamp - lastTimeStamp) > interval);
        lastTimeStamp = block.timestamp;
        growFlower(0);
        (uint256 fee, address feeToken) = _getFeeDetails();
        _transfer(fee, feeToken);
    }

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, IpfsUri[0]);
    }

    function growFlower(uint256 _tokenId) public {
        if (flowerStage(_tokenId) >= 2) {
            return;
        }
        uint256 newVal = flowerStage(_tokenId) + 1;
        string memory newUri = IpfsUri[newVal];
        _setTokenURI(_tokenId, newUri);
    }

    function flowerStage(uint256 _tokenId) public view returns (uint256) {
        string memory _uri = tokenURI(_tokenId);
        if (compareStrings(_uri, IpfsUri[0])) {
            return 0;
        }
        if (compareStrings(_uri, IpfsUri[1])) {
            return 1;
        }
        return 2;
    }

    function compareStrings(
        string memory a,
        string memory b
    ) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
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

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    receive() external payable {}
}
