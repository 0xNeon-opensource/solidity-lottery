// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Lottery
/// @author @0xNeon - https://github.com/0xNeon-opensource
/// @notice Win magic internet money with this lottery contract!
contract Lottery is Ownable {
    address payable[] public participants;
    uint256 public minimumParticipants;

    modifier ensureMinimumParticipantsHaveEntered() {
        require(participants.length >= minimumParticipants, "Minimum number of participants not reached.");
        _;
    }

    constructor() {
        minimumParticipants = 1;
    }

    function enterInLottery() external {
        participants.push(payable(msg.sender));
    }

    function getParticipantCount() external view returns (uint256) {
        return participants.length;
    }

    function setMinimumParticipants(uint256 n) external onlyOwner {
        minimumParticipants = n;
    }

    function getRandomNumber() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, participants.length)));
    }

    function chooseWinner()
        external view
        onlyOwner
        ensureMinimumParticipantsHaveEntered
        returns (address payable) {
        return participants[getRandomNumber() % participants.length];
    }
}
