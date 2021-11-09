const { expect } = require('chai')
const chai = require('chai')
const BN = require('bn.js')
const skipIf = require('mocha-skip-if')
chai.use(require('chai-bn')(BN))
const fs = require('fs')
const { deployments, getChainId } = require('hardhat')
const { networkConfig, developmentChains } = require('../helper-hardhat-config')

skip.if(!developmentChains.includes(network.name)).
  describe('EthArNFT Unit Tests', async function () {
    let contract

    beforeEach(async () => {
      await deployments.fixture(['ethArNft'])
      const EthArNFT = await deployments.get("EthArNFT")
      contract = await ethers.getContractAt("EthArNFT", EthArNFT.address)
    })

    it('should deploy', async () => {
      const address = contract.address;
      expect(address).to.not.eql(0x0);
      expect(address).to.not.be.empty;
      expect(address).to.not.be.null;
      expect(address).to.not.be.undefined;
    })
  })
