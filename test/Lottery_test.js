const { expect } = require('chai')
const chai = require('chai')
const chaiAsPromised = require('chai-as-promised')
chai.use(chaiAsPromised).should()
const BN = require('bn.js')
const skipIf = require('mocha-skip-if')
chai.use(require('chai-bn')(BN))
const fs = require('fs')
const { deployments, waffle } = require('hardhat')
const { developmentChains } = require('../helper-hardhat-config')

skip.if(!developmentChains.includes(network.name)).
  describe('Lottery', async function () {
    const provider = waffle.provider;
    let contract;
    let signers;
    let signerAddresses;
    let exampleAddress;

    before(async () => {
      signers = await ethers.getSigners();
      signerAddresses = signers.map((signer) => signer.address);
      exampleAddress = ethers.utils.getAddress('0x23e8B49d0a0B5bb4A9D662E63b2d545fe2007148');
    });

    beforeEach(async () => {
      await deployments.fixture(['lottery']);
      const Lottery = await deployments.get("Lottery");
      contract = await ethers.getContractAt("Lottery", Lottery.address);
    })

    it('deploys successfully', async () => {
      const address = contract.address;
      expect(address).to.not.eql(0x0);
      expect(address).to.not.be.empty;
      expect(address).to.not.be.null;
      expect(address).to.not.be.undefined;
    })

    describe('Getters and Setters', async () => {
      it('onlyOwner can set minimum participants', async () => {
        await contract.setMinimumParticipants(5);
        await contract.connect(signers[1]).setMinimumParticipants(5).should.be.rejected;
      });

      it('can get minimum participants', async () => {
        await contract.setMinimumParticipants(15);

        const minimumParticipants = await contract.minimumParticipants();

        expect(minimumParticipants).to.eq(15);
      });

      it('gets number of participants', async () => {
        await enterAllTwentySignersIntoLottery(signers, contract);

        const participantCount = await contract.getParticipantCount();

        expect(participantCount).to.eq(20);
      });

      it('onlyOwner can set entrance fee', async () => {
        await contract.setEntranceFeeInWei(1000);
        await contract.connect(signers[1]).setEntranceFeeInWei(1000).should.be.rejected;
      });

      it('can get entrance fee', async () => {
        await contract.setEntranceFeeInWei(1);

        const entranceFee = await contract.entranceFeeInWei();

        expect(entranceFee).to.eq(1);
      });

      it('onlyOwner can set house payout percentage', async () => {
        await contract.setHousePayoutPercentage(10);
        await contract.connect(signers[1]).setHousePayoutPercentage(10).should.be.rejected;
      });

      it('can get house payout percentage', async () => {
        await contract.setHousePayoutPercentage(10);

        const payoutPercentage = await contract.housePayoutPercentage();

        expect(payoutPercentage).to.eq(10);
      });

      it('house payout percentage cannot be more than 100', async () => {
        await contract.setHousePayoutPercentage(101).should.be.rejected;
      });

      it('onlyOwner can set house payout address', async () => {
        await contract.setHousePayoutAddress(exampleAddress);
        await contract.connect(signers[1]).setHousePayoutAddress(exampleAddress).should.be.rejected;
      });

      it('can get house payout address', async () => {
        await contract.setHousePayoutAddress(exampleAddress);

        const payoutAddress = await contract.housePayoutAddress();

        expect(payoutAddress).to.eq(exampleAddress);
      });
    });

    describe('Entering the lottery', () => {
      it('rejects if payment is not enough', async () => {
        await contract.setEntranceFeeInWei(1);

        await contract.enterInLottery(
          { value: ethers.utils.parseEther("0").toHexString() }
        ).should.be.rejected;
      });

      it('should enter into lottery if payment is correct', async () => {
        await contract.setEntranceFeeInWei(1000);
        const entranceFee = await contract.entranceFeeInWei().then((fee) => fee.toString());
        await contract.enterInLottery({ value: entranceFee });

        let participant = await contract.participants(0);

        expect(participant).to.eq(signers[0].address);
      });

      it('enters multiple participants into lottery', async () => {
        await contract.enterInLottery();
        await contract.connect(signers[1]).enterInLottery();
        await contract.connect(signers[2]).enterInLottery();
        await contract.connect(signers[3]).enterInLottery();

        let participant0 = await contract.participants(0);
        let participant1 = await contract.participants(1);
        let participant2 = await contract.participants(2);
        let participant3 = await contract.participants(3);

        expect(participant0).to.eq(signers[0].address);
        expect(participant1).to.eq(signers[1].address);
        expect(participant2).to.eq(signers[2].address);
        expect(participant3).to.eq(signers[3].address);
      });
    });

    describe('Winning the lottery', () => {
      it('onlyOwner can call chooseWinner()', async () => {
        await enterAllTwentySignersIntoLottery(signers, contract);

        await contract.connect(signers[1]).chooseWinner().should.be.rejected;
      });
  
      it('should fail to choose winner when there are NOT enough participants', async () => {
        await contract.setMinimumParticipants(1);
  
        await contract.chooseWinner().should.be.rejected;
      });
  
      it('should fail to choose winner when there 0 participants', async () => {
        await contract.setMinimumParticipants(0);
  
        await contract.chooseWinner().should.be.rejected;
      });
  
      it('should choose winner when there are enough participants', async () => {
        await contract.enterInLottery();
  
        expect(await contract.chooseWinner()).to.emit(contract, 'LotteryWon').withArgs(signerAddresses[0]);
      });

      it('should pay house address the correct percentage when winner is chosen', async () => {
        await contract.setEntranceFeeInWei(10);
        await contract.setHousePayoutPercentage(5);
        await contract.setHousePayoutAddress(exampleAddress);
        await enterAllTwentySignersIntoLottery(signers, contract);
        // Fee = 10; Number of participants = 20; House payout = 5%
        const expectedPayoutForHouse = 10 * 20 * .05;

        expect(await provider.getBalance(exampleAddress)).to.eq(0);
        await contract.chooseWinner();
        
        expect(await provider.getBalance(exampleAddress)).to.eq(expectedPayoutForHouse);
      });
    });
  });

async function enterAllTwentySignersIntoLottery(signers, contract) {
  const entranceFee = await contract.entranceFeeInWei().then((fee) => fee.toString());

  signers.forEach(async signer => {
    await contract.connect(signer).enterInLottery({ value: entranceFee });
  });
}