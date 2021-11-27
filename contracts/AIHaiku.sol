// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "hardhat/console.sol";

contract AIHaiku is ERC721URIStorage, Ownable {
    using ECDSA for bytes32;

    uint256 public constant maxSupply = 575;
    uint256 public constant price = 0.01 ether;
    // Mon Nov 29 2021 00:59:30, or Sun Nov 28 2021 19:59:30 EST
    uint256 public constant mintTimeWhitelist = 1638147570;
    // Mon Nov 29 2021 01:59:30, or Sun Nov 28 2021 20:59:30
    uint256 public constant mintTimePublic = 1638151170;

    uint256 public tokenCounter;
    address private trueSigner;

    mapping(string => bool) tokenUriExists;

    event CreatedAIHaiku(uint256 indexed tokenId, string tokenURI);

    modifier doesNotExceedMaxSupply() {
        require(totalSupply() < maxSupply, "Max supply has already been minted.");
        _;
    }

    modifier hasMinimumPayment(uint256 value) {
        require(value >= price);
        _;
    }

    modifier tokenUriDoesNotExist(string memory tokenUri) {
        require(!tokenUriExists[tokenUri], "Token URI exists");
        _;
    }

    modifier ensureValidSignature(string memory tokenUri, bytes memory signature) {
        bytes32 hashedTokenUri = keccak256(abi.encodePacked(tokenUri)).toEthSignedMessageHash();
        address signer = hashedTokenUri.recover(signature);
        require(signer == trueSigner, "Message not signed by true signer.");
        _;
    }

    modifier ensureTimeToMint() {
        // require(block.timestamp >= mintTimePublic, "Time to mint not yet reached.");
        require(block.timestamp >= 0, "Time to mint not yet reached.");
        _;
    }

    constructor() ERC721("AI Haiku", "HAIKU") {
        tokenCounter = 0;
        trueSigner = 0xDBA800F4Da03Dba3f604268aeC2AD9EB28A055A4;
    }

    function mint(string memory tokenUri, bytes memory signature)
        external payable
        doesNotExceedMaxSupply
        hasMinimumPayment(msg.value)
        tokenUriDoesNotExist(tokenUri)
        ensureValidSignature(tokenUri, signature)
        ensureTimeToMint
    {
        _safeMint(msg.sender, tokenCounter);
        _setTokenURI(tokenCounter, tokenUri);
        tokenCounter = tokenCounter + 1;
        tokenUriExists[tokenUri] = true;
        emit CreatedAIHaiku(tokenCounter, tokenUri);
    }

    function totalSupply() public view returns (uint256) {
        return tokenCounter;
    }

    function updateSignerPublicKey(address newAddress) external onlyOwner {
        trueSigner = newAddress;
    }

    function getReqAddress() public view returns (address) {
        return msg.sender;
    }
}
