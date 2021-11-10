// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "hardhat/console.sol";

contract AIHaiku is ERC721URIStorage, Ownable {
    using ECDSA for bytes32;

    uint256 public constant MAX_SUPPLY = 3333;
    uint256 public constant PRICE = 0.01 ether;

    uint256 public tokenCounter;
    address private trueSigner;

    mapping(string => bool) tokenUriExists;

    event CreatedAIHaiku(uint256 indexed tokenId, string tokenURI);

    modifier doesNotExceedMaxSupply() {
        require(totalSupply() < MAX_SUPPLY, "Max supply has already been minted.");
        _;
    }

    modifier hasMinimumPayment(uint256 value) {
        require(value >= PRICE);
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
}
