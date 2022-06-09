// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/test.sol";

import {BytesLib} from 'solidity-bytes-utils/BytesLib.sol';

import {stringsExt} from '../src/stringsExt.sol';

contract LZ77assemblyTest is DSTest {
    using stringsExt for *;

    uint256 constant MIN_MATCH = 1;

    function testIterate() public {
        string memory stringToCompress = "simple test simple test";
        //string memory stringToCompress = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus sed tempor magna. Curabitur at lobortis sem. Aliquam pretium, nunc ut consectetur venenatis, enim augue rutrum nibh, vitae iaculis est augue ut est. Praesent vehicula lacinia enim in faucibus. Maecenas quis porttitor nisi.In dolor orci, auctor ut cursus vitae, dignissim vitae ante. Nulla nec lorem commodo, vehicula massa a, vulputate mi.Pellentesque nibh nibh, bibendum quis vestibulum sit amet, vulputate convallis turpis. Integer non ornare purus.Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Maecenas in tortor sed enim condimentum rhoncus a eu orci. Vivamus odio lorem, tincidunt eget nisi ac, venenatis interdum neque. Aliquam quis neque a dui efficitur pellentesque vitae eu augue. Nulla at tempus magna. In augue orci, vehicula non imperdiet a, sagittis vitae massa. Duis ultricies ante nisi, eget dignissim lorem lacinia sit amet. Nullam luctus, diam eget elementum bibendum, ex odio rhoncus est, eu congue orci enim non tortor. Vestibulum non diam at lorem tincidunt rutrum sit amet sit amet leo. Mauris lorem risus, fermentum vitae eros ut, mollis faucibus sapien. Nullam sed mauris mi. Vivamus sit amet metus pharetra, ultricies ligula a, pellentesque nibh. Mauris eget tortor massa. Phasellus et quam vitae erat posuere pulvinar at et nunc. Fusce est erat, aliquam hendrerit congue eu, egestas eget turpis. Nunc vel eros ac lectus interdum ullamcorper nec id dui. Phasellus ut velit euismod, malesuada lacus quis, porta nisi. Sed ultricies lorem id lorem iaculis, a sodales mi semper. Proin feugiat justo ut urna commodo, rutrum mattis sem tincidunt. Donec condimentum a urna sit amet blandit. Sed lorem leo, ullamcorper sit amet feugiat ac, elementum eu lorem. Suspendisse tristique interdum ex, ut laoreet lacus gravida vel. Nullam varius cursus volutpat. Aenean pellentesque orci aliquet posuere pellentesque. Vestibulum in enim sed sapien tincidunt mollis nec et nunc metus.";
        bytes memory compressedData;

        
        bytes memory rawData = abi.encodePacked(stringToCompress);

        stringsExt.slice memory rawSlice = rawData.toSliceBytes();
        uint256 rawSliceLength = rawSlice._len;

        

        stringsExt.slice memory searchSlice = stringsExt.slice(0, rawSlice._ptr);
        stringsExt.slice memory aheadSlice = stringsExt.slice(15, rawSlice._ptr);

        bytes1 nextCharacter;
        uint256 position;
        uint256 length;

        uint256 idx = 0;

        unchecked{
            while(idx < rawSliceLength-1) {
                //LZ77_match(rawData.slice(searchIndex, idx).toSliceBytes(), rawData.slice(idx, aheadLen).toSliceBytes());
                emit log_string("new loop iteration- searchSlice Len:");
                emit log_uint(searchSlice._len);
                emit log_string(string.concat(" search: '", searchSlice.toString(), "' ahead:'", aheadSlice.toString(), "'"));
                (position, length) = LZ77_match(searchSlice, aheadSlice);
                
                if (idx + length >= rawSliceLength) {
                    nextCharacter = hex"00";
                } else {
                    nextCharacter = rawData[idx+length];
                }

                compressedData = bytes.concat(compressedData, encode(position, length, nextCharacter));

                emit log_string("before increment- searchSlice Len:");
                emit log_uint(searchSlice._len);

                (searchSlice, aheadSlice, idx) = alignSlices(searchSlice, aheadSlice, length, idx, rawSliceLength);

                emit log_string("after increment- searchSlice Len:");
                emit log_uint(searchSlice._len);
                
            }
        }

        //return compressedData;
        emit log_uint(compressedData.length);
        emit log_bytes(compressedData);

        /*
        
        stringsExt.slice memory searchSlice = stringsExt.slice(0, rawSlice._ptr);
        stringsExt.slice memory aheadSlice = stringsExt.slice(15, rawSlice._ptr);

        uint256 end = rawSlice._ptr + rawSlice._len;

        uint256 idx;
        uint256 matchPosition;
        uint256 matchLength;
        bytes1 nextCharacter;

        unchecked {
            for (; aheadSlice._ptr<end; aheadSlice._ptr++) {
                
                emit log_string(string.concat(" search: '", searchSlice.toString(), "' ahead: '", aheadSlice.toString(), "'"));

                (matchPosition, matchLength) = LZ77_match(searchSlice, aheadSlice);

                if (idx + matchLength >= rawSlice._len) {
                    nextCharacter = hex"00";
                } else {
                    nextCharacter = rawData[idx+matchLength];
                }

                emit log_uint(matchPosition);
                emit log_uint(matchLength);
                emit log_uint(idx);
                
                compressedData = bytes.concat(compressedData, encode(matchPosition, matchLength, nextCharacter));

                aheadSlice._len = (aheadSlice._ptr + aheadSlice._len) > end ? aheadSlice._len-1 : 15;
                emit log_uint(aheadSlice._len);

                if (searchSlice._len == 4095) {
                    searchSlice._ptr++;
                } else {
                    searchSlice._len++;
                }

                if (matchLength != 0) {
                    aheadSlice._ptr += matchLength;
                    idx += matchLength;
                } else {
                    idx++;
                }
            }
        }

        emit log_uint(compressedData.length);
        emit log_bytes(compressedData);
        */

    }

    // set the slices to their new places to avoid incrementing in a funny way
    function alignSlices(stringsExt.slice memory _searchSlice, stringsExt.slice memory _aheadSlice, uint256 _length, uint256 _idx, uint256 _rawSliceLength) private pure returns (stringsExt.slice memory, stringsExt.slice memory, uint256) {
        if (_length != 0) {
            
            _searchSlice._len += _length + 1; 

            _aheadSlice._ptr += _length+1; 
            _aheadSlice._len = (_idx+15) < _rawSliceLength ? 15 : _rawSliceLength-_idx;
            _idx += _length+1;
        } else {
            
            _searchSlice._len++; 

            _aheadSlice._ptr++; 
            _aheadSlice._len = (_idx+15) < _rawSliceLength ? 15 : _rawSliceLength-_idx;
            _idx++;
        }

        // whether idx is at least 4095
        _searchSlice._ptr += _idx > 4095 ? 1: 0; 

        return (_searchSlice, _aheadSlice, _idx);
    }

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
                    return ((searchLength - position)+1, length);   
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



}
