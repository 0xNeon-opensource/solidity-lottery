// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

import "hardhat/console.sol";

contract EthArNFT is ERC721URIStorage, Ownable {
    using ECDSA for bytes32;

    uint256 public constant MAX_SUPPLY = 100;
    uint256 public constant PRICE = 0.001 ether;

    uint256 public tokenCounter;
    address private trueSigner;

    mapping(string => bool) tokenUriExists;

    event CreatedEthArNFT(uint256 indexed tokenId, string tokenURI);

    modifier doesNotExceedMaxSupply() {
        require(totalSupply() < MAX_SUPPLY);
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


    constructor() ERC721("Eth Arweave NFT", "ETHARNFT") {
        tokenCounter = 0;
        trueSigner = 0xDBA800F4Da03Dba3f604268aeC2AD9EB28A055A4;
    }

    function mint(string memory tokenUri, bytes memory signature)
        public payable
        doesNotExceedMaxSupply
        hasMinimumPayment(msg.value)
        tokenUriDoesNotExist(tokenUri)
        ensureValidSignature(tokenUri, signature)
    {
        _safeMint(msg.sender, tokenCounter);
        _setTokenURI(tokenCounter, tokenUri);
        tokenCounter = tokenCounter + 1;
        tokenUriExists[tokenUri] = true;
        emit CreatedEthArNFT(tokenCounter, tokenUri);
    }

    function totalSupply() public view returns (uint256) {
        return tokenCounter + 1;
    }
}
