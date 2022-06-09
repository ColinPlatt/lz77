// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {BytesLib} from 'solidity-bytes-utils/BytesLib.sol';
import {stringsExt} from '../src/stringsExt.sol';

library LZ77Lib {
    using BytesLib for bytes;
    using stringsExt for stringsExt.slice;
    using stringsExt for bytes;

    uint256 constant MIN_MATCH = 3;

    function LZ77_match(stringsExt.slice memory search, stringsExt.slice memory ahead) private pure returns (uint256 position, uint256 length) {
        stringsExt.slice memory _ahead = ahead;
        uint256 searchLength = search._len;

        length = ahead._len;

        unchecked {
            while(length > MIN_MATCH) {
                length--;
                _ahead._len = length;
                
                if(search.contains(_ahead)) {
                    position = search.lastIndex(_ahead);
                    return ((searchLength - position)+1, length+1);   
                }
            }
        }
        return (0,0);
    }

    function encode(uint256 pos, uint256 len, bytes1 nextChar) private pure returns (bytes memory) {

        bytes memory output = new bytes(3);

        output[0] = bytes1(uint8(uint256(pos) & 255));
        output[1] = bytes1(uint8(((uint256(pos) & 3840) >> 8) | ((len & 15) << 4)));
        output[2] = nextChar;

        return output;

    }

    function compress(bytes memory rawData) internal pure returns (bytes memory compressedData) {
        stringsExt.slice memory _rawData = rawData.toSliceBytes();
        uint256 rawDataLength = _rawData._len;

        bytes1 nextCharacter;

        uint256 searchIndex;
        uint256 aheadLen;

        uint256 idx = 0;

        unchecked{
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
        }

        return compressedData;

    }

    function compressAsm(bytes memory rawData) internal pure returns (bytes memory compressedData) {
        stringsExt.slice memory _rawData = rawData.toSliceBytes();
        uint256 rawDataLength = _rawData._len;

        bytes1 nextCharacter;

        uint256 searchIndex;
        uint256 aheadLen;

        uint256 idx = 0;
        uint256 position;
        uint256 length;

        unchecked{
            while(idx < rawDataLength-1) {
                // whether idx is at least 4095
                searchIndex = idx > 4095 ? idx - 4095: 0; 
                aheadLen = (idx+15) < rawDataLength ? 15 : rawDataLength-idx;

                (position, length) = LZ77_match(stringsExt.slice(idx, searchIndex+_rawData._ptr), stringsExt.slice(aheadLen, idx+_rawData._ptr));
                
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
        }

        return compressedData;

    }

}