// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import {stringsExt} from './stringsExt.sol';

library stringArr{
    using stringsExt for *;

    enum ErrorCode{
        ERR_NONE,
        ERR_NOT_FOUND
    } 

    function LastIndex(string memory source, string memory find) internal pure returns (uint) {
        return LastIndex(source.toSlice(), find.toSlice());

        
    }

    function LastIndex(stringsExt.slice memory source, string memory find) internal pure returns (uint) {
        return LastIndex(source, find.toSlice());
    }

    function LastIndex(stringsExt.slice memory source, stringsExt.slice memory find) internal pure returns (uint) {
        uint256 foundLen = source.rfind(find)._len;

        if (foundLen != 0) {
            return source.rfind(find)._len - find._len + 1;
        } else {
            return 0;
        }
    }

    // we count in the string array from index 0
    function partialString(stringsExt.slice memory self, uint start, uint end) internal pure returns (stringsExt.slice memory) {
        
        require(start <= end, "invalid array2");
        require(start <= self._len, "invalid array1");

        uint _end = end >= self._len ? self._len-1 : end;  

        
        if (start == 0) {
            if(end == start) {
                // if an empty array, return it
                self._len = 1;
            } else if(end == self._len-1) {
                // if requesting the full array, return it
                return self;
            } else {
                self._len = _end + 1;
            }
        } else {
            self._ptr += start;
            self._len = _end + 1 - start;
        }

        return self;
    }

}