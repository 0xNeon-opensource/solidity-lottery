// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Lottery
/// @author @0xNeon - https://github.com/0xNeon-opensource
/// @notice Win magic internet money with this lottery contract!
contract Lottery is Ownable {
    address payable[] public participants;
    uint256 public minimumParticipants;
    uint256 public entranceFeeInWei;
    uint256 public housePayoutPercentage;
    address public housePayoutAddress;

    event LotteryWon(address, uint256);

    modifier minimumParticipantsHaveEntered() {
        require(
            participants.length >= minimumParticipants && participants.length > 0,
            "Minimum number of participants not reached."
        );
        _;
    }

    modifier entranceFeePaid(uint256 paid) {
        require(paid >= entranceFeeInWei, "Please provide the entrance fee.");
        _;
    }

    constructor(uint256 _minimumParticipants) {
        minimumParticipants = _minimumParticipants;
    }

    function enterInLottery() external payable entranceFeePaid(msg.value) {
        participants.push(payable(msg.sender));
    }

    function getParticipantCount() external view returns (uint256) {
        return participants.length;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function setMinimumParticipants(uint256 n) external onlyOwner {
        minimumParticipants = n;
    }

    function setEntranceFeeInWei(uint256 n) external onlyOwner {
        entranceFeeInWei = n;
    }

    function setHousePayoutPercentage(uint256 n) external onlyOwner {
        require(n <= 100, "House payout percentage cannot be more than 100.");
        housePayoutPercentage = n;
    }

    function setHousePayoutAddress(address a) external onlyOwner {
        housePayoutAddress = a;
    }

    function unsafeGetRandomNumber() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, participants.length)));
    }

    function chooseWinner()
        external
        onlyOwner
        minimumParticipantsHaveEntered {
            payable(housePayoutAddress).transfer(address(this).balance * housePayoutPercentage / 100);
            address winner = participants[unsafeGetRandomNumber() % participants.length];
            uint256 winnerPayout = address(this).balance;
            // Change transfer to call. See: https://solidity-by-example.org/sending-ether/
            payable(winner).transfer(winnerPayout);
            emit LotteryWon(winner, winnerPayout);
    }
}
