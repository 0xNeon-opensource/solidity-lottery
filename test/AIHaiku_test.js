const { expect } = require('chai')
const web3 = require('web3')
const chai = require('chai')
const chaiAsPromised = require('chai-as-promised')
chai.use(chaiAsPromised).should()
const BN = require('bn.js')
const skipIf = require('mocha-skip-if')
chai.use(require('chai-bn')(BN))
const fs = require('fs')
const { deployments, getChainId } = require('hardhat')
const { networkConfig, developmentChains } = require('../helper-hardhat-config')

// Kept for manual testing:
// const tokenSignaturePairs = {
//   0: {
//     tokenUri: 'http://localhost:1984/fy9R3-Cm1wN9k3HHzvci-nBDbx5IzyollMHnG3VDOao',
//     signature: '0xe63fd0ddc7e34de7044b9603b6134a0154de0d0fdd1ff7b011497d045e27678a7cd83ab16a7f446fc3c4e71901f1273fd5f2a4996cbcb24b58917e5271ae7ae81b'
//   },
//   1: {
//     tokenUri: 'http://localhost:1984/nlgIUiHduvHU-B7H6udu9Behe3nvhAJlAIq5OU7jiKY',
//     signature: '0x8146fdd97aaad67a5dcfb851772c0fb4b243106a841b635a793716f5f685ee445ff7d0d3d39a84703c979fc70b3825caf91ade881a5a40edac5e2bf21610d9181b'
//   },
//   2: {
//     tokenUri: 'http://localhost:1984/c0ag0Yu2cZSKYzQbNnV5Cn7P7c67xaMuA8PpjTMyo8Y',
//     signature: '0x186b888c5ed115c7d28823dde41130fddc917da967835ea8ed041b07ba58a0be3fcb49fbdc1193d8871fe09f7baf34c9f38cfc4805c32e792c3601245907cc691b'
//   },
//   3: {
//     tokenUri: 'http://localhost:1984/eW5X43GedCRf7gsSPFLcWTZlSFArgux0NnPIhkRpAp8',
//     signature: '0xce8d1e6a79ae074b6ce2585f9368fdb42363485efabfb41448b5dd98e1aa345d3f3951cfd2c563837d2d04474980f54bfb2767912a008f21ace9cfe0eb2ca0a51c'
//   }
// }
skip.if(!developmentChains.includes(network.name)).
  describe('AI Haiku Unit Tests', async function () {
    let contract;
    const MINT_PRICE_IN_ETHER = ethers.utils.parseEther("0.01").toHexString();

    beforeEach(async () => {
      await deployments.fixture(['aiHaiku']);
      const AIHaiku = await deployments.get("AIHaiku");
      contract = await ethers.getContractAt("AIHaiku", AIHaiku.address);
    })

    describe('deployment', async () => {
      it('deploys successfully', async () => {
        const address = contract.address;
        expect(address).to.not.eql(0x0);
        expect(address).to.not.be.empty;
        expect(address).to.not.be.null;
        expect(address).to.not.be.undefined;
      })

      it('has a name', async () => {
        const name = await contract.name();
        expect(name).to.eql('AI Haiku');
      });

      it('has a symbol', async () => {
        const symbol = await contract.symbol();
        expect(symbol).to.eql('HAIKU');
      });
    })

    describe('minting', async () => {
      it('mints and gets total supply', async () => {
        const tokenSignaturePairs = generateTokenSignaturePairs(2);

        await contract.mint(
          tokenSignaturePairs[0].tokenUri,
          tokenSignaturePairs[0].signature,
          { value: MINT_PRICE_IN_ETHER }
        );
        let totalSupply = await contract.totalSupply();

        assert.equal(totalSupply.toNumber(), 1);

        await contract.mint(
          tokenSignaturePairs[1].tokenUri,
          tokenSignaturePairs[1].signature,
          { value: MINT_PRICE_IN_ETHER }
        );
        totalSupply = await contract.totalSupply();

        assert.equal(totalSupply.toNumber(), 2);
      })

      it('gets tokenURI', async () => {
        const tokenSignaturePairs = generateTokenSignaturePairs(1);

        await contract.mint(
          tokenSignaturePairs[0].tokenUri,
          tokenSignaturePairs[0].signature,
          { value: MINT_PRICE_IN_ETHER }
        );

        const tokenUri = await contract.tokenURI(0);
        assert.equal(tokenUri, tokenSignaturePairs[0].tokenUri);
      })

      it('rejects if payment is not enough', async () => {
        const tokenSignaturePairs = generateTokenSignaturePairs(1);
        await contract.mint(
          tokenSignaturePairs[0].tokenUri,
          tokenSignaturePairs[0].signature,
          { value: ethers.utils.parseEther("0").toHexString() }
        ).should.be.rejected;
      })

      it('rejects if uses a previously used tokenUri', async () => {
        const tokenSignaturePairs = generateTokenSignaturePairs(1);
        await contract.mint(
          tokenSignaturePairs[0].tokenUri,
          tokenSignaturePairs[0].signature,
          { value: MINT_PRICE_IN_ETHER }
        );

        await contract.mint(
          tokenSignaturePairs[0].tokenUri,
          tokenSignaturePairs[0].signature,
          { value: MINT_PRICE_IN_ETHER }
        ).should.be.rejected;
      })

      it('rejects if uses an invalid signature', async () => {
        const tokenSignaturePairs = generateTokenSignaturePairs(2);
        await contract.mint(
          tokenSignaturePairs[0].tokenUri,
          // using signature from another token
          tokenSignaturePairs[1].signature,
          { value: MINT_PRICE_IN_ETHER }
        ).should.be.rejected;
      })

      it('rejects if has reached max supply and tries to mint', async () => {
        const maxSupply = await contract.MAX_SUPPLY().then(bn => bn.toNumber());
        const tokenSignaturePairs = generateTokenSignaturePairs(maxSupply + 1);

        for (let index = 0; index < maxSupply; index++) {
          await contract.mint(
            tokenSignaturePairs[index].tokenUri,
            tokenSignaturePairs[index].signature,
            { value: MINT_PRICE_IN_ETHER }
          );
        }

        // Minting one too many...
        await contract.mint(
          tokenSignaturePairs[tokenSignaturePairs.length - 1].tokenUri,
          tokenSignaturePairs[tokenSignaturePairs.length - 1].signature,
          { value: MINT_PRICE_IN_ETHER }
        ).should.be.rejected;
      })
    })
  })


const generateTokenSignaturePairs = (numberOfPairs) => {
  const web3Instance = new web3();

  let tokenUri;
  let signature;
  const tokenSignaturePairs = [];
  for (let index = 0; index < numberOfPairs; index++) {
    tokenUri = 'https://arweave.net/testTokenUri_' + index.toString();
    const hashedMessage = web3Instance.utils.soliditySha3({ type: 'string', value: tokenUri });
    signature = web3Instance.eth.accounts.sign(hashedMessage, process.env.TRUE_SIGNER_PRIVATE_KEY);

    tokenSignaturePairs.push({ tokenUri, signature: signature.signature });
  };
  return tokenSignaturePairs;
}
