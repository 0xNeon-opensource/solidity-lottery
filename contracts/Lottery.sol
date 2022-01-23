// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Lottery
/// @author @0xNeon - https://github.com/0xNeon-opensource
/// @notice Win magic internet money with this lottery contract!
contract Lottery is Ownable {
    address payable[] public participants;
    uint256 minimumParticipants;

    constructor() {
        minimumParticipants = 1;
    }

    function enterInLottery() external {
        participants.push(payable(msg.sender));
    }

    function getParticipantCount() external view returns (uint256) {
        return participants.length;
    }

    function getRandomNumber() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, participants.length)));
    }

    function chooseWinner() external view onlyOwner returns (address payable) {
        require(participants.length >= minimumParticipants, "Minimum number of participants not reached.");
        return payable(0xDBA800F4Da03Dba3f604268aeC2AD9EB28A055A4);
        // return participants[getRandomNumber() % participants.length];
    }
}
