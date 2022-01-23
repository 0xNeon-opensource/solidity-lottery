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

    modifier ensureMinimumParticipantsHaveEntered() {
        require(participants.length >= minimumParticipants, "Minimum number of participants not reached.");
        _;
    }

    constructor(uint256 _minimumParticipants) {
        minimumParticipants = _minimumParticipants;
    }

    function enterInLottery() external payable {
        require(msg.value >= entranceFeeInWei, "Please provide the entrance fee.");
        participants.push(payable(msg.sender));
    }

    function getParticipantCount() external view returns (uint256) {
        return participants.length;
    }

    function setMinimumParticipants(uint256 n) external onlyOwner {
        minimumParticipants = n;
    }

    function setEntranceFeeInWei(uint256 n) external onlyOwner {
        entranceFeeInWei = n;
    }

    function unsafeGetRandomNumber() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, participants.length)));
    }

    function chooseWinner()
        external view
        onlyOwner
        ensureMinimumParticipantsHaveEntered
        returns (address payable) {
        return participants[unsafeGetRandomNumber() % participants.length];
    }
}
