// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import {stringsExt} from './stringsExt.sol';

library stringArr{
    using stringsExt for *;

    function LastIndex(string memory source, string memory search) internal pure returns (uint) {
        stringsExt.slice memory _search = search.toSlice();

        return source.toSlice().rfind(_search)._len - _search._len;
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

}