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

        //check that we can pull the root node info
        assertEq0(rootNode.symbol, hex'6162');
        assertEq(rootNode.weight, 11);

        //check that we can pull the left node info
        assertEq0(decodePointer(rootNode.left).symbol, hex'61');
        assertEq(decodePointer(rootNode.left).weight, 5);

        // check that we can pull the right node info
        assertEq0(decodePointer(rootNode.right).symbol, hex'62');
        assertEq(decodePointer(rootNode.right).weight, 6);

    }

    function decodePointer(stringsExt.slice memory _pointer) internal pure returns (Node memory) {
        return abi.decode(_pointer.toByteString(), (Node));
    }



}