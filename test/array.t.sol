// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/test.sol";

import {BytesLib} from 'solidity-bytes-utils/BytesLib.sol';
import {stringsExt} from '../src/stringsExt.sol';
import {stringArr} from '../src/stringArr.sol';

contract arrayTest is DSTest {
    using stringsExt for *;
    using stringArr for *;

    function testArrayChop() public {

        bytes memory testBytesString = abi.encodePacked("simple test simple test");

        emit log_bytes(testBytesString);

        emit log_bytes(BytesLib.slice(testBytesString, 0, 8));

        emit log_bytes(BytesLib.slice(testBytesString, 8, 23-8));

    }

    function testArrayChopExt() public {

        bytes memory testBytesString = abi.encodePacked("simple test simple test");

        emit log_bytes(testBytesString);

        emit log_bytes(testBytesString.toSliceBytes().partialString(0, 0).toByteString());

    }

}