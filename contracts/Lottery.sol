// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Lottery
/// @author @0xNeon - https://github.com/0xNeon-opensource
/// @notice Win magic internet money with this lottery contract!
contract Lottery is Ownable {

    address payable[] public participants;

    constructor() {

    }

    function enterInLottery() external {
        participants.push(payable(msg.sender));
    }
}
