// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/test.sol";

//import {strings} from '../lib/solidity-stringutils/src/stringsExt.sol';
import {BytesLib} from 'solidity-bytes-utils/BytesLib.sol';

import {stringsExt} from '../src/stringsExt.sol';

contract lz77Test is DSTest {
    //using strings for *;
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

        emit log_uint(LastIndex(source, search));

    }

    function LastIndex(string memory source, string memory search) internal pure returns (uint) {
        stringsExt.slice memory _search = search.toSlice();

        return source.toSlice().rfind(_search)._len - _search._len;
    }

    function testUntil() public {

        string memory source = "go gopher go gop gopher go";
        uint index = 5;

        emit log_string(until(source.toSlice(), index).toString());

    }

    


    function until(stringsExt.slice memory self, uint index) internal pure returns (stringsExt.slice memory) {
        if (self._len < index) {
            return self;
        }

        self._len = index + 1;

        return self;
    }

    function testStrPart() public {

        string memory source = "go gopher go gop gopher go";
        uint startIdx = 10;
        uint endIdx = 20;

        emit log_string(partialString(source.toSlice(), startIdx, endIdx).toString());

    }

    // we count in the string array from index 0
    function partialString(stringsExt.slice memory self, uint start, uint end) internal pure returns (stringsExt.slice memory) {
        require(start < end && start < self._len && end < self._len, "invalid array");
        
        // if requesting the full array, return it
        if (start == 0 && end == self._len-1) {
            return self;
        }

        // if requesting the array from the beginning, but not to the end
        if(start == 0) {
            self._len = end + 1;
        } else {
            self._ptr += start;
            self._len = end + 1 - start;
        }

        return self;
    }
    

    function testHASH() public {
        bytes3 _prev = bytes3(uint24(97));
        bytes3 _data = bytes3(uint24(98));
        bytes3 _hash_mask = bytes3(uint24(32767));
        emit log_bytes(abi.encodePacked(HASH(_prev, _data, _hash_mask,5)));
        emit log_uint(uint24(HASH(_prev, _data, _hash_mask,5)));

        emit log_bytes(abi.encodePacked((_prev << 12)^_data));

        bytes3 expected = bytes3(uint24(3138));
        emit log_bytes(abi.encodePacked(expected));
        
    }


    //((prev << 8) + (prev >> 8) + (data << 4)) & s.hash_mask;
    //((prev << s.hash_shift) ^ data) & s.hash_mask
    function HASH(bytes3 prev, bytes3 data, bytes3 hash_mask, uint hash_shift) internal returns (bytes3) {
        return ((prev << hash_shift) ^ data) & hash_mask;
    }

    function LZ77_search(bytes memory search, bytes memory look_ahead) public returns (bytes3 HASH) {



    }

    //assertTrue("foobar".toSlice().contains("o".toSlice()));


    

    /*
    function _match(bytes memory search, bytes memory ahead) public pure returns (uint256 position, uint256 length) {
        uint256 searchLength = search.length;

        for (length = ahead.length; length > 0; length--) {
            position = 
        }
    }
    */



    
    function setUp() public {}

    
}

library LZ77 {

    struct Huffman {
        uint256[] counts;
        uint256[] symbols;
    }

    function _codes(
        Huffman memory lencode,
        Huffman memory distcode
    ) internal returns (Huffman memory, Huffman memory) {
        // Decoded symbol
        uint256 symbol;
        // Length for copy
        uint256 len;
        // Distance for copy
        uint256 dist;
        // TODO Solidity doesn't support constant arrays, but these are fixed at compile-time
        // Size base for length codes 257..285
        uint16[29] memory lens =
            [
                3,
                4,
                5,
                6,
                7,
                8,
                9,
                10,
                11,
                13,
                15,
                17,
                19,
                23,
                27,
                31,
                35,
                43,
                51,
                59,
                67,
                83,
                99,
                115,
                131,
                163,
                195,
                227,
                258
            ];
        // Extra bits for length codes 257..285
        uint8[29] memory lext =
            [
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                1,
                1,
                1,
                1,
                2,
                2,
                2,
                2,
                3,
                3,
                3,
                3,
                4,
                4,
                4,
                4,
                5,
                5,
                5,
                5,
                0
            ];
        // Offset base for distance codes 0..29
        uint16[30] memory dists =
            [
                1,
                2,
                3,
                4,
                5,
                7,
                9,
                13,
                17,
                25,
                33,
                49,
                65,
                97,
                129,
                193,
                257,
                385,
                513,
                769,
                1025,
                1537,
                2049,
                3073,
                4097,
                6145,
                8193,
                12289,
                16385,
                24577
            ];
        // Extra bits for distance codes 0..29
        uint8[30] memory dext =
            [
                0,
                0,
                0,
                0,
                1,
                1,
                2,
                2,
                3,
                3,
                4,
                4,
                5,
                5,
                6,
                6,
                7,
                7,
                8,
                8,
                9,
                9,
                10,
                10,
                11,
                11,
                12,
                12,
                13,
                13
            ];

        

        return(lencode, distcode);

    }



}


/*

    {0, 0, 1, 1},
    {1, 0, 2, 2},
    {2, 0, 3, 3},
    {3, 0, 4, 4},
    {4, 1, 5, 6},
    {5, 1, 7, 8},
    {6, 2, 9, 12},
    {7, 2, 13, 16},
    {8, 3, 17, 24},
    {9, 3, 25, 32},
    {10, 4, 33, 48},
    {11, 4, 49, 64},
    {12, 5, 65, 96},
    {13, 5, 97, 128},
    {14, 6, 129, 192},
    {15, 6, 193, 256},
    {16, 7, 257, 384},
    {17, 7, 385, 512},
    {18, 8, 513, 768},
    {19, 8, 769, 1024},
    {20, 9, 1025, 1536},
    {21, 9, 1537, 2048},
    {22, 10, 2049, 3072},
    {23, 10, 3073, 4096},
    {24, 11, 4097, 6144},
    {25, 11, 6145, 8192},
    {26, 12, 8193, 12288},
    {27, 12, 12289, 16384},
    {28, 13, 16385, 24576},
    {29, 13, 24577, 32768},

      */