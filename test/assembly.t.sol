// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/test.sol";

import {BytesLib} from 'solidity-bytes-utils/BytesLib.sol';

import {stringsExt} from '../src/stringsExt.sol';

contract assemblyTest is DSTest {
    using stringsExt for *;

    function testIterate() public {
        //string memory stringToCompress = "simple test simple test";
        string memory stringToCompress = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus sed tempor magna. Curabitur at lobortis sem. Aliquam pretium, nunc ut consectetur venenatis, enim augue rutrum nibh, vitae iaculis est augue ut est. Praesent vehicula lacinia enim in faucibus. Maecenas quis porttitor nisi.In dolor orci, auctor ut cursus vitae, dignissim vitae ante. Nulla nec lorem commodo, vehicula massa a, vulputate mi.Pellentesque nibh nibh, bibendum quis vestibulum sit amet, vulputate convallis turpis. Integer non ornare purus.Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Maecenas in tortor sed enim condimentum rhoncus a eu orci. Vivamus odio lorem, tincidunt eget nisi ac, venenatis interdum neque. Aliquam quis neque a dui efficitur pellentesque vitae eu augue. Nulla at tempus magna. In augue orci, vehicula non imperdiet a, sagittis vitae massa. Duis ultricies ante nisi, eget dignissim lorem lacinia sit amet. Nullam luctus, diam eget elementum bibendum, ex odio rhoncus est, eu congue orci enim non tortor. Vestibulum non diam at lorem tincidunt rutrum sit amet sit amet leo. Mauris lorem risus, fermentum vitae eros ut, mollis faucibus sapien. Nullam sed mauris mi. Vivamus sit amet metus pharetra, ultricies ligula a, pellentesque nibh. Mauris eget tortor massa. Phasellus et quam vitae erat posuere pulvinar at et nunc. Fusce est erat, aliquam hendrerit congue eu, egestas eget turpis. Nunc vel eros ac lectus interdum ullamcorper nec id dui. Phasellus ut velit euismod, malesuada lacus quis, porta nisi. Sed ultricies lorem id lorem iaculis, a sodales mi semper. Proin feugiat justo ut urna commodo, rutrum mattis sem tincidunt. Donec condimentum a urna sit amet blandit. Sed lorem leo, ullamcorper sit amet feugiat ac, elementum eu lorem. Suspendisse tristique interdum ex, ut laoreet lacus gravida vel. Nullam varius cursus volutpat. Aenean pellentesque orci aliquet posuere pellentesque. Vestibulum in enim sed sapien tincidunt mollis nec et nunc metus.";
        stringsExt.slice memory rawSlice = stringToCompress.toSlice();

        emit log_uint(rawSlice._len);
        emit log_uint(rawSlice._ptr);

        stringsExt.slice memory rawSlice2 = "simple test simple test".toSlice();

        emit log_uint(rawSlice2._len);
        emit log_uint(rawSlice2._ptr);

        stringsExt.slice memory aheadSlice = stringsExt.slice(15, rawSlice._ptr);

        uint256 end = rawSlice._ptr + rawSlice._len;

        for (; aheadSlice._ptr<end; aheadSlice._ptr++) {
            aheadSlice._len = (aheadSlice._ptr + aheadSlice._len) > end ? aheadSlice._len-1 : 15;
            //emit log_uint(aheadSlice._len);
            //emit log_string(aheadSlice.toString());
        }

    }

    function testUpdateString() public {

        string memory stringSaved = "simple test simple test";

        stringsExt.slice memory rawSlice = stringSaved.toSlice();

        emit log_uint(getMemSize());

        //emit log_uint(rawSlice._len);
        //emit log_uint(rawSlice._ptr);

        stringSaved = "test simple test simple test";

        rawSlice = stringSaved.toSlice();

        //emit log_uint(rawSlice._len);
        //emit log_uint(rawSlice._ptr);

        emit log_uint(getMemSize());





    }

    function testMod() public {

        stringsExt.slice memory rawSlice = "test simple test simple test".toSlice();

        //emit log_bytes(rawSlice.toByteString());

        emit log_uint(getMemSize());

        rawSlice = modString(rawSlice, "new input test");

        //emit log_bytes(rawSlice.toByteString());

        emit log_uint(getMemSize());

    }

    function getMemSize() internal pure returns (uint _mSize) {
        assembly {
            _mSize := msize()
        }
    }

    function modString(stringsExt.slice memory self, string memory newString) internal pure returns (stringsExt.slice memory) {

        uint ptr = self._ptr;

        assembly {
            for { let len := 0 } lt(len, 32) { len := add(len,1) } 
            {
                mstore8(ptr, len)
                ptr := add(ptr,1)
            }
        }


        return stringsExt.slice (32, self._ptr);

    }



    function rfindPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) internal pure returns (uint) {
        uint ptr;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask;
                if (needlelen > 0) {
                    mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));
                }

                bytes32 needledata;
                assembly { needledata := and(mload(needleptr), mask) }

                ptr = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                assembly { ptrdata := and(mload(ptr), mask) }

                while (ptrdata != needledata) {
                    if (ptr <= selfptr)
                        return selfptr;
                    ptr--;
                    assembly { ptrdata := and(mload(ptr), mask) }
                }
                return ptr + needlelen;
            } else {
                // For long needles, use hashing
                bytes32 hash;
                assembly { hash := keccak256(needleptr, needlelen) }
                ptr = selfptr + (selflen - needlelen);
                while (ptr >= selfptr) {
                    bytes32 testHash;
                    assembly { testHash := keccak256(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr + needlelen;
                    ptr -= 1;
                }
            }
        }
        return selfptr;
    }

}