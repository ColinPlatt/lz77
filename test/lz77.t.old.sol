

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;



import "ds-test/test.sol";

//import {strings} from '../lib/solidity-stringutils/src/stringsExt.sol';
import {BytesLib} from 'solidity-bytes-utils/BytesLib.sol';

import {stringsExt} from '../src/stringsExt.sol';
import {stringArr} from '../src/stringArr.sol';

contract lz77Test is DSTest {

/*
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

    

    function LZ77_match(string memory rawData, uint256 searchIndex, uint256 idx, uint256 aheadIndex) internal returns (LZ77 memory) {
        stringsExt.slice memory _rawData = rawData.toSlice();
        stringsExt.slice memory search = _rawData.copy().partialString(searchIndex, idx);

        emit log_string(string.concat("search string: '",search.toString(),"'"));

        uint256 searchLength = search.len();

        stringArr.ErrorCode err;
        uint256 position;

        stringsExt.slice memory ahead = _rawData.copy().partialString(idx+1, aheadIndex);

        emit log_string(string.concat("ahead string: '", ahead.toString(), "'"));

        uint256 length = ahead.len();

        while(length > 0) {

            length--;
            
            ahead = ahead.copy().partialString(0, length);
            emit log_string(string.concat("ahead string: '", ahead.toString(), "'"));
            
            if(search.contains(ahead)) {
                (err, position) = search.LastIndex(ahead);
                //emit log_uint(searchLength);
                //emit log_uint(position);
                return LZ77(searchLength - position, length+1);   
            }
        }

        return (LZ77(0,0));

    }

    function encode(LZ77 memory _entry, bytes1 nextChar) internal pure returns (string memory) {

        bytes memory output = new bytes(3);

        output[0] = bytes1(uint8(uint256(_entry.position) & 255));
        output[1] = bytes1(uint8(((uint256(_entry.position) & 3840) >> 8) | ((_entry.length & 15) << 4)));
        output[2] = nextChar;

        return string(output);

    }

    function compress(string memory rawData) internal returns (string memory compressedData) {
        uint256 rawDataLength = rawData.toSlice().len();
        bytes1 nextCharacter;

        uint256 searchIndex;
        uint256 aheadIndex;

        for(uint256 idx = 0; idx < rawDataLength; idx++) {
            // whether idx is at least 4095
            searchIndex = idx > 4095 ? idx - 4095: 0; 
            aheadIndex = (idx+15) < rawDataLength ? (idx+15) : rawDataLength-1;

            LZ77 memory nextMatch = LZ77_match(rawData, searchIndex, idx, aheadIndex);
            if(idx > 6) {
                //emit log_uint(idx);
                //emit log_uint(aheadIndex);
                emit log_uint(nextMatch.position);
                emit log_uint(nextMatch.length);
            }
            

            if (idx + nextMatch.length >= rawDataLength) {
                nextCharacter = hex"00";
            } else {
                
                nextCharacter = abi.encodePacked(rawData)[idx + nextMatch.length];
                /*if (nextMatch.length != 0) {
                    emit log_string("nextChar Index");
                    emit log_uint(idx + nextMatch.length);
                    emit log_string(string(abi.encodePacked(nextCharacter)));
                
                }
                

                
            }

            string memory toEncode = encode(nextMatch, nextCharacter);        
            
            emit log_string(string.concat("old compressed: '", compressedData, "' | encoding: '", toEncode, "'"));
            compressedData = string.concat(compressedData, toEncode);    
            //compressedData = string.concat(compressedData, encode(nextMatch, nextCharacter));
            
            
            if (nextMatch.position != 0) {
                idx += nextMatch.length;
            }
            
            
        }

        return compressedData;

    }

    function _testLZ77Match() public {

        //string memory testString = "go find something out there go go gopher now";

        string memory testString = "simple test simple test";

        LZ77 memory searchResult = LZ77_match(testString, 0,8,22);

        emit log_uint(searchResult.position);
        emit log_uint(searchResult.length);

    }


    function _testEncode() public {

        LZ77 memory testMatch = LZ77(3, 1);

        string memory testOutput = encode(testMatch, hex'00');

        emit log_bytes(abi.encodePacked(testOutput));

        //assertEq(testOutput, string(abi.encodePacked(uint8(151),uint8(56),uint8(97))));


    }

    function testLZ77Compress() public {

        //string memory stringToCompress = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus sed tempor magna. Curabitur at lobortis sem. Aliquam pretium, nunc ut consectetur venenatis, enim augue rutrum nibh, vitae iaculis est augue ut est. Praesent vehicula lacinia enim in faucibus. Maecenas quis porttitor nisi.In dolor orci, auctor ut cursus vitae, dignissim vitae ante. Nulla nec lorem commodo, vehicula massa a, vulputate mi.Pellentesque nibh nibh, bibendum quis vestibulum sit amet, vulputate convallis turpis. Integer non ornare purus.Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Maecenas in tortor sed enim condimentum rhoncus a eu orci. Vivamus odio lorem, tincidunt eget nisi ac, venenatis interdum neque. Aliquam quis neque a dui efficitur pellentesque vitae eu augue. Nulla at tempus magna. In augue orci, vehicula non imperdiet a, sagittis vitae massa. Duis ultricies ante nisi, eget dignissim lorem lacinia sit amet. Nullam luctus, diam eget elementum bibendum, ex odio rhoncus est, eu congue orci enim non tortor. Vestibulum non diam at lorem tincidunt rutrum sit amet sit amet leo. Mauris lorem risus, fermentum vitae eros ut, mollis faucibus sapien. Nullam sed mauris mi. Vivamus sit amet metus pharetra, ultricies ligula a, pellentesque nibh. Mauris eget tortor massa. Phasellus et quam vitae erat posuere pulvinar at et nunc. Fusce est erat, aliquam hendrerit congue eu, egestas eget turpis. Nunc vel eros ac lectus interdum ullamcorper nec id dui. Phasellus ut velit euismod, malesuada lacus quis, porta nisi. Sed ultricies lorem id lorem iaculis, a sodales mi semper. Proin feugiat justo ut urna commodo, rutrum mattis sem tincidunt. Donec condimentum a urna sit amet blandit. Sed lorem leo, ullamcorper sit amet feugiat ac, elementum eu lorem. Suspendisse tristique interdum ex, ut laoreet lacus gravida vel. Nullam varius cursus volutpat. Aenean pellentesque orci aliquet posuere pellentesque. Vestibulum in enim sed sapien tincidunt mollis nec et nunc metus.";
        string memory stringToCompress = "simple test simple test";

        string memory compressedString = compress(stringToCompress);

        emit log_string(compressedString);
        emit log_bytes(abi.encodePacked(compressedString));

        bytes memory expectedResult = abi.encodePacked(hex"00007300006900006D00007000006C0000650000200000740310730310200CB000");

        assertEq0(abi.encodePacked(compressedString), expectedResult);

    }



    


    
    function setUp() public {}

    */
    
}
