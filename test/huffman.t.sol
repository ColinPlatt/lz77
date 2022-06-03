// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/test.sol";

import {BytesLib} from 'solidity-bytes-utils/BytesLib.sol';

import {stringsExt} from '../src/stringsExt.sol';

contract huffmanTest is DSTest {
    using stringsExt for *;

    struct Node {
        bytes symbol;
        uint8 code;
        uint8 weight;
        stringsExt.slice left;
        stringsExt.slice right;
    }

    function testNesting() public {
        
        Node memory lNode = Node(hex"61", 0, 5, stringsExt.slice(0,0), stringsExt.slice(0,0));
        Node memory rNode = Node(hex"62", 0, 6, stringsExt.slice(0,0), stringsExt.slice(0,0));

        Node memory rootNode = Node(abi.encodePacked(lNode.symbol, rNode.symbol), 0, lNode.weight + rNode.weight, abi.encode(lNode).toSliceBytes(), abi.encode(rNode).toSliceBytes());

        emit log_bytes(rootNode.symbol);
        emit log_uint(rootNode.weight);
        emit log_uint(rootNode.left._ptr);
        emit log_uint(rootNode.left._len);
        emit log_uint(rootNode.right._ptr);
        emit log_uint(rootNode.right._len);

        

    }



}