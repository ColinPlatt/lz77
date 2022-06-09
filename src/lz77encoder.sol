// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {LZ77Lib} from './LZ77Lib.sol';

contract lz77encoder {
    using LZ77Lib for *;

    function compress(string memory input) public pure returns (bytes memory output) {
        return abi.encodePacked(input).compress();
    }

}
