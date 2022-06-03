// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/test.sol";

//import {strings} from '../lib/solidity-stringutils/src/stringsExt.sol';
import {BytesLib} from 'solidity-bytes-utils/BytesLib.sol';

import {stringsExt} from '../src/stringsExt.sol';
import {stringArr} from '../src/stringArr.sol';

contract lz77Test is DSTest {
    using stringArr for *;
    using stringsExt for *;
    using BytesLib for bytes;

    
    
    struct LZ77 {
        uint256[] positions;
        uint256[] lens;
    }

    function testStruct() public {

        LZ77 memory structTest = LZ77(new uint256[](10), new uint256[](10));

        for (uint256 i = 0; i<10; i++) {
            structTest.positions[i] = i;
            structTest.lens[i] = i*2+1;
        }

        bytes memory structBytes = abi.encode(structTest);

        emit log_uint(structBytes.toSliceBytes()._len);
        emit log_uint(structBytes.toSliceBytes()._ptr);

        LZ77 memory structTest2 = LZ77(new uint256[](10), new uint256[](10));

        for (uint256 i = 0; i<10; i++) {
            structTest2.positions[i] = i*3;
            structTest2.lens[i] = i*4+1;
        }

        bytes memory structBytes2 = abi.encode(structTest2);

        emit log_uint(structBytes2.toSliceBytes()._len);
        emit log_uint(structBytes2.toSliceBytes()._ptr);

        LZ77 memory revertStruct2 = abi.decode(structBytes2, (LZ77));

        for (uint256 i = 0; i<10; i++) {
            assertEq(revertStruct2.positions[i], structTest2.positions[i]);
            assertEq(revertStruct2.lens[i], structTest2.lens[i]);
        }



    }


    function testLastIndex() public {

        stringsExt.slice memory source = "go gopher go gop gopher go".toSlice();
        string memory search = "gop";

        emit log_uint(source.rfind(search.toSlice())._len - search.toSlice()._len);

    }

    function testLastIndexFunc() public {

        string memory source = "go gopher go gop gopher go";
        string memory search = "gop";

        emit log_uint(source.LastIndex(search));

    }   

    function testStrPart() public {

        string memory source = "go gopher go gop gopher go";
        uint startIdx = 10;
        uint endIdx = 20;

        emit log_string(source.toSlice().partialString(startIdx, endIdx).toString());

    }

    


    
    function setUp() public {}

    
}
