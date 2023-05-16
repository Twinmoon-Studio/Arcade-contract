// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

contract Percentages {
    function calculate(uint256 amount, uint256 bps) public pure returns (uint256) {
        require((amount * bps) >= 10_000);
        return amount * bps / 10_000;
    } 
}