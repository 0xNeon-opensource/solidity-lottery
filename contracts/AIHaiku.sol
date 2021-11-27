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
    // (GMT): Monday, November 29, 2021 1:00:00 AM
    // (CST): Sunday, November 28, 2021 7:00:00 PM
    uint256 public constant mintTimeWhitelist = 1638147600;

    // (GMT): Monday, November 29, 2021 2:00:00 AM
    // (CST): Sunday, November 28, 2021 8:00:00 PM
    uint256 public constant mintTimePublic = 1638151200;

    uint256 public tokenCounter;
    address private trueSigner;

    mapping(string => bool) tokenUriExists;
    mapping(address => uint256) whitelistedAddressToTimesMinted;

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

    modifier ensureValidSignature(string memory message, bytes memory signature, bool isWhitelisted) {
        bytes memory encodedMessage = isWhitelisted ? abi.encodePacked("Whitelisted:", message) : abi.encodePacked(message);
        bytes32 hashedMessage = keccak256(encodedMessage).toEthSignedMessageHash();
        address signer = hashedMessage.recover(signature);
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

    function whitelistMint(string memory tokenUri, bytes memory signature)
        external payable
        hasMinimumPayment(msg.value)
        ensureValidSignature(tokenUri, signature, true)
    {
        mint(tokenUri);
        whitelistedAddressToTimesMinted[msg.sender] = 1;
    }

    function publicMint(string memory tokenUri, bytes memory signature)
        external payable
        hasMinimumPayment(msg.value)
        ensureValidSignature(tokenUri, signature, false)
    {
        mint(tokenUri);
    }

    function mint(string memory tokenUri)
        private
        doesNotExceedMaxSupply
        tokenUriDoesNotExist(tokenUri)
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
