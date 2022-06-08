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
        uint256 position;
        uint256 length;
    }

    function _decodePointer(stringsExt.slice memory _pointer) internal pure returns (LZ77 memory) {
        return abi.decode(_pointer.toByteString(), (LZ77));
    }

    
    function LZ77_match(stringsExt.slice memory search, stringsExt.slice memory ahead) internal pure returns (uint256 position, uint256 length) {
        stringsExt.slice memory _ahead = ahead;

        uint256 searchLength = search.len();

        length = ahead.len();

        while(length > 2) {

            length--;
            
            _ahead = _ahead.copy().partialString(0, length);
            
            if(search.contains(_ahead)) {
                position = search.LastIndex(_ahead);
                return ((searchLength - position)+1, length+1);   
            }
        }

        return (0,0);

    }

    function encode(uint256 pos, uint256 len, bytes1 nextChar) internal pure returns (bytes memory) {

        bytes memory output = new bytes(3);

        output[0] = bytes1(uint8(uint256(pos) & 255));
        output[1] = bytes1(uint8(((uint256(pos) & 3840) >> 8) | ((len & 15) << 4)));
        output[2] = nextChar;

        return output;

    }

    function compress(bytes memory rawData) internal pure returns (bytes memory compressedData) {
        stringsExt.slice memory _rawData = rawData.toSliceBytes();
        uint256 rawDataLength = _rawData.len();

        bytes1 nextCharacter;

        uint256 searchIndex;
        uint256 aheadLen;

        uint256 idx = 0;

        while(idx < rawDataLength-1) {
            // whether idx is at least 4095
            searchIndex = idx > 4095 ? idx - 4095: 0; 
            aheadLen = (idx+15) < rawDataLength ? 15 : rawDataLength-idx;

            (uint256 position, uint256 length) = LZ77_match(rawData.slice(searchIndex, idx).toSliceBytes(), rawData.slice(idx, aheadLen).toSliceBytes());
            
            if (idx + length >= rawDataLength) {
                nextCharacter = hex"00";
            } else {
                nextCharacter = rawData[idx+length];
            }

            compressedData = bytes.concat(compressedData, encode(position, length, nextCharacter));    

            if (length != 0) {
                idx += length+1;
            } else {
                idx++;
            }
        }

        return compressedData;

    }

    function _testLZ77CompressShort() public {

        //string memory stringToCompress = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus sed tempor magna. Curabitur at lobortis sem. Aliquam pretium, nunc ut consectetur venenatis, enim augue rutrum nibh, vitae iaculis est augue ut est. Praesent vehicula lacinia enim in faucibus. Maecenas quis porttitor nisi.In dolor orci, auctor ut cursus vitae, dignissim vitae ante. Nulla nec lorem commodo, vehicula massa a, vulputate mi.Pellentesque nibh nibh, bibendum quis vestibulum sit amet, vulputate convallis turpis. Integer non ornare purus.Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Maecenas in tortor sed enim condimentum rhoncus a eu orci. Vivamus odio lorem, tincidunt eget nisi ac, venenatis interdum neque. Aliquam quis neque a dui efficitur pellentesque vitae eu augue. Nulla at tempus magna. In augue orci, vehicula non imperdiet a, sagittis vitae massa. Duis ultricies ante nisi, eget dignissim lorem lacinia sit amet. Nullam luctus, diam eget elementum bibendum, ex odio rhoncus est, eu congue orci enim non tortor. Vestibulum non diam at lorem tincidunt rutrum sit amet sit amet leo. Mauris lorem risus, fermentum vitae eros ut, mollis faucibus sapien. Nullam sed mauris mi. Vivamus sit amet metus pharetra, ultricies ligula a, pellentesque nibh. Mauris eget tortor massa. Phasellus et quam vitae erat posuere pulvinar at et nunc. Fusce est erat, aliquam hendrerit congue eu, egestas eget turpis. Nunc vel eros ac lectus interdum ullamcorper nec id dui. Phasellus ut velit euismod, malesuada lacus quis, porta nisi. Sed ultricies lorem id lorem iaculis, a sodales mi semper. Proin feugiat justo ut urna commodo, rutrum mattis sem tincidunt. Donec condimentum a urna sit amet blandit. Sed lorem leo, ullamcorper sit amet feugiat ac, elementum eu lorem. Suspendisse tristique interdum ex, ut laoreet lacus gravida vel. Nullam varius cursus volutpat. Aenean pellentesque orci aliquet posuere pellentesque. Vestibulum in enim sed sapien tincidunt mollis nec et nunc metus.";
        bytes memory stringToCompress = abi.encodePacked("simple test simple test");

        bytes memory compressedString = compress(stringToCompress);

        emit log_string(string(compressedString));
        emit log_bytes(compressedString);

        bytes memory expectedResult = abi.encodePacked(hex"00007300006900006D00007000006C0000650000200000740000650000730000740000200CB000");

        assertEq0(abi.encodePacked(compressedString), expectedResult);

    }

    function testLZ77CompressLong() public {

        bytes memory stringToCompress = abi.encodePacked("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus sed tempor magna. Curabitur at lobortis sem. Aliquam pretium, nunc ut consectetur venenatis, enim augue rutrum nibh, vitae iaculis est augue ut est. Praesent vehicula lacinia enim in faucibus. Maecenas quis porttitor nisi.In dolor orci, auctor ut cursus vitae, dignissim vitae ante. Nulla nec lorem commodo, vehicula massa a, vulputate mi.Pellentesque nibh nibh, bibendum quis vestibulum sit amet, vulputate convallis turpis. Integer non ornare purus.Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Maecenas in tortor sed enim condimentum rhoncus a eu orci. Vivamus odio lorem, tincidunt eget nisi ac, venenatis interdum neque. Aliquam quis neque a dui efficitur pellentesque vitae eu augue. Nulla at tempus magna. In augue orci, vehicula non imperdiet a, sagittis vitae massa. Duis ultricies ante nisi, eget dignissim lorem lacinia sit amet. Nullam luctus, diam eget elementum bibendum, ex odio rhoncus est, eu congue orci enim non tortor. Vestibulum non diam at lorem tincidunt rutrum sit amet sit amet leo. Mauris lorem risus, fermentum vitae eros ut, mollis faucibus sapien. Nullam sed mauris mi. Vivamus sit amet metus pharetra, ultricies ligula a, pellentesque nibh. Mauris eget tortor massa. Phasellus et quam vitae erat posuere pulvinar at et nunc. Fusce est erat, aliquam hendrerit congue eu, egestas eget turpis. Nunc vel eros ac lectus interdum ullamcorper nec id dui. Phasellus ut velit euismod, malesuada lacus quis, porta nisi. Sed ultricies lorem id lorem iaculis, a sodales mi semper. Proin feugiat justo ut urna commodo, rutrum mattis sem tincidunt. Donec condimentum a urna sit amet blandit. Sed lorem leo, ullamcorper sit amet feugiat ac, elementum eu lorem. Suspendisse tristique interdum ex, ut laoreet lacus gravida vel. Nullam varius cursus volutpat. Aenean pellentesque orci aliquet posuere pellentesque. Vestibulum in enim sed sapien tincidunt mollis nec et nunc metus.");

        bytes memory compressedString = compress(stringToCompress);

        emit log_bytes(compressedString);
    }

    
    function setUp() public {}

    
}
