pragma solidity ^0.8.0;

import 'ds-test/test.sol';
import {stringsExt} from '../src/stringsExt.sol';

contract StringsTest is DSTest {
	using stringsExt for *;


    function abs(int x) private pure returns (int) {
        if(x < 0)
            return -x;
        return x;
    }

    function sign(int x) private pure returns (int) {
        return x == 0 ? int(0) : (x < 0 ? -1 : int(1));
    }

    function assertEq0(string memory a, string memory b) internal {
        assertEq0(bytes(a), bytes(b));
    }

    function assertEq0(stringsExt.slice memory a, stringsExt.slice memory b) internal {
    	assertEq0(a.toString(), b.toString());
    }

    function assertEq0(stringsExt.slice memory a, string memory b) internal {
        assertEq0(a.toString(), b);
    }

    function assertEq0Bytes(stringsExt.slice memory a, bytes memory b) internal {
        assertEq0(a.toByteString(), b);
    }

	function testSliceToString() public {
		string memory test = "Hello, world!";
		assertEq0(test, test.toSlice().toString());
	}

    function testSliceToByteString() public {
        bytes memory test = abi.encodePacked("Hello, world!");
        assertEq0(test, test.toSliceBytes().toByteString());
	}

    function testBytes32Len() public {
        bytes32 test;
        for(uint i = 0; i <= 32; i++) {
            assertEq(i, test.len());
            test = bytes32((uint(test) / 0x100) | 0x2000000000000000000000000000000000000000000000000000000000000000);
        }
    }


    function testToSliceB32() public {
        assertEq0(bytes32("foobar").toSliceB32(), "foobar".toSlice());
    }

    function testToSliceBytes() public {
        assertEq0(abi.encodePacked("foobar").toSliceBytes(), "foobar".toSlice());
    }

    function testCopy() public {
        string memory test = "Hello, world!";
        stringsExt.slice memory s1 = test.toSlice();
        stringsExt.slice memory s2 = s1.copy();
        s1._len = 0;
        assertEq(s2._len, bytes(test).length);
    }

    function testCopyBytes() public {
        bytes memory test = abi.encodePacked("Hello, world!");
        stringsExt.slice memory s1 = test.toSliceBytes();
        stringsExt.slice memory s2 = s1.copy();
        s1._len = 0;
        assertEq(s2._len, test.length);
    }

    function testLen() public {
        assertEq("".toSlice().len(), 0);
        assertEq("Hello, world!".toSlice().len(), 13);
        assertEq(unicode"naïve".toSlice().len(), 5);
        assertEq(unicode"こんにちは".toSlice().len(), 5);
    }

    function testLenBytes() public {
        assertEq(abi.encodePacked("").toSliceBytes().len(), 0);
        assertEq(abi.encodePacked("Hello, world!").toSliceBytes().len(), 13);
        assertEq(abi.encodePacked(unicode"naïve").toSliceBytes().len(), 5);
        assertEq(abi.encodePacked(unicode"こんにちは").toSliceBytes().len(), 5);
    }

    function testEmpty() public {
        assertTrue("".toSlice().empty());
        assertTrue(!"x".toSlice().empty());
    }

    function testEmptyBytes() public {
        assertTrue(abi.encodePacked("").toSliceBytes().empty());
        assertTrue(!abi.encodePacked("x").toSliceBytes().empty());
    }

    function testEquals() public {
        assertTrue("".toSlice().equals("".toSlice()));
        assertTrue("foo".toSlice().equals("foo".toSlice()));
        assertTrue(!"foo".toSlice().equals("bar".toSlice()));
    }

    function testEqualsBytes() public {
        assertTrue(abi.encodePacked("").toSliceBytes().equals(abi.encodePacked("").toSliceBytes()));
        assertTrue(abi.encodePacked("foo").toSliceBytes().equals(abi.encodePacked("foo").toSliceBytes()));
        assertTrue(!abi.encodePacked("foo").toSliceBytes().equals(abi.encodePacked("bar").toSliceBytes()));
    }

    function testNextRune() public {
        stringsExt.slice memory s = unicode"a¡ࠀ𐀡".toSlice();
        assertEq0(s.nextRune(), "a");
        assertEq0(s, unicode"¡ࠀ𐀡");
        assertEq0(s.nextRune(), unicode"¡");
        assertEq0(s, unicode"ࠀ𐀡");
        assertEq0(s.nextRune(), unicode"ࠀ");
        assertEq0(s, unicode"𐀡");
        assertEq0(s.nextRune(), unicode"𐀡");
        assertEq0(s, "");
        assertEq0(s.nextRune(), "");
    }

    function testNextRuneBytes() public {
        stringsExt.slice memory s = abi.encodePacked(unicode"a¡ࠀ𐀡").toSliceBytes();
        assertEq0Bytes(s.nextRune(), abi.encodePacked("a"));
        assertEq0Bytes(s, abi.encodePacked(unicode"¡ࠀ𐀡"));
        assertEq0Bytes(s.nextRune(), abi.encodePacked(unicode"¡"));
        assertEq0Bytes(s, abi.encodePacked(unicode"ࠀ𐀡"));
        assertEq0Bytes(s.nextRune(), abi.encodePacked(unicode"ࠀ"));
        assertEq0Bytes(s, abi.encodePacked(unicode"𐀡"));
        assertEq0Bytes(s.nextRune(), abi.encodePacked(unicode"𐀡"));
        assertEq0Bytes(s, abi.encodePacked(""));
        assertEq0Bytes(s.nextRune(), abi.encodePacked(""));
    }

    function testOrd() public {
        assertEq("a".toSlice().ord(), 0x61);
        assertEq(unicode"¡".toSlice().ord(), 0xA1);
        assertEq(unicode"ࠀ".toSlice().ord(), 0x800);
        assertEq(unicode"𐀡".toSlice().ord(), 0x10021);
    }

    function testOrdBytes() public {
        assertEq(abi.encodePacked("a").toSliceBytes().ord(), 0x61);
        assertEq(abi.encodePacked(unicode"¡").toSliceBytes().ord(), 0xA1);
        assertEq(abi.encodePacked(unicode"ࠀ").toSliceBytes().ord(), 0x800);
        assertEq(abi.encodePacked(unicode"𐀡").toSliceBytes().ord(), 0x10021);
    }

    function testCompare() public {

        assertEq(sign("foobie".toSlice().compare("foobie".toSlice())), 0);
        assertEq(sign("foobie".toSlice().compare("foobif".toSlice())), -1);
        assertEq(sign("foobie".toSlice().compare("foobid".toSlice())), 1);
        assertEq(sign("foobie".toSlice().compare("foobies".toSlice())), -1);
        assertEq(sign("foobie".toSlice().compare("foobi".toSlice())), 1);
        assertEq(sign("foobie".toSlice().compare("doobie".toSlice())), 1);
        assertEq(sign("01234567890123456789012345678901".toSlice().compare("012345678901234567890123456789012".toSlice())), -1);
				assertEq(sign("0123456789012345678901234567890123".toSlice().compare("1123456789012345678901234567890123".toSlice())), -1);
        assertEq(sign("foo.bar".toSlice().split(".".toSlice()).compare("foo".toSlice())), 0);
    }

    function testStartsWith() public {
        stringsExt.slice memory s = "foobar".toSlice();
        assertTrue(s.startsWith("foo".toSlice()));
        assertTrue(!s.startsWith("oob".toSlice()));
        assertTrue(s.startsWith("".toSlice()));
        assertTrue(s.startsWith(s.copy().rfind("foo".toSlice())));
    }

    function testBeyond() public {
        stringsExt.slice memory s = "foobar".toSlice();
        assertEq0(s.beyond("foo".toSlice()), "bar");
        assertEq0(s, "bar");
        assertEq0(s.beyond("foo".toSlice()), "bar");
        assertEq0(s.beyond("bar".toSlice()), "");
        assertEq0(s, "");
    }

    function testEndsWith() public {
        stringsExt.slice memory s = "foobar".toSlice();
        assertTrue(s.endsWith("bar".toSlice()));
        assertTrue(!s.endsWith("oba".toSlice()));
        assertTrue(s.endsWith("".toSlice()));
        assertTrue(s.endsWith(s.copy().find("bar".toSlice())));
    }

    function testUntil() public {
        stringsExt.slice memory s = "foobar".toSlice();
        assertEq0(s.until("bar".toSlice()), "foo");
        assertEq0(s, "foo");
        assertEq0(s.until("bar".toSlice()), "foo");
        assertEq0(s.until("foo".toSlice()), "");
        assertEq0(s, "");
    }

    function testFind() public {
        assertEq0("abracadabra".toSlice().find("abracadabra".toSlice()), "abracadabra");
        assertEq0("abracadabra".toSlice().find("bra".toSlice()), "bracadabra");
        assertTrue("abracadabra".toSlice().find("rab".toSlice()).empty());
        assertTrue("12345".toSlice().find("123456".toSlice()).empty());
        assertEq0("12345".toSlice().find("".toSlice()), "12345");
        assertEq0("12345".toSlice().find("5".toSlice()), "5");
    }

    function testRfind() public {
        assertEq0("abracadabra".toSlice().rfind("bra".toSlice()), "abracadabra");
        assertEq0("abracadabra".toSlice().rfind("cad".toSlice()), "abracad");
        assertTrue("12345".toSlice().rfind("123456".toSlice()).empty());
        assertEq0("12345".toSlice().rfind("".toSlice()), "12345");
        assertEq0("12345".toSlice().rfind("1".toSlice()), "1");
    }

    function testSplit() public {
        stringsExt.slice memory s = "foo->bar->baz".toSlice();
        stringsExt.slice memory delim = "->".toSlice();
        assertEq0(s.split(delim), "foo");
        assertEq0(s, "bar->baz");
        assertEq0(s.split(delim), "bar");
        assertEq0(s.split(delim), "baz");
        assertTrue(s.empty());
        assertEq0(s.split(delim), "");
        assertEq0(".".toSlice().split(".".toSlice()), "");
    }

    function testRsplit() public {
        stringsExt.slice memory s = "foo->bar->baz".toSlice();
        stringsExt.slice memory delim = "->".toSlice();
        assertEq0(s.rsplit(delim), "baz");
        assertEq0(s.rsplit(delim), "bar");
        assertEq0(s.rsplit(delim), "foo");
        assertTrue(s.empty());
        assertEq0(s.rsplit(delim), "");
    }

    function testCount() public {
        assertEq("1121123211234321".toSlice().count("1".toSlice()), 7);
        assertEq("ababababa".toSlice().count("aba".toSlice()), 2);
    }

    function testContains() public {
        assertTrue("foobar".toSlice().contains("f".toSlice()));
        assertTrue("foobar".toSlice().contains("o".toSlice()));
        assertTrue("foobar".toSlice().contains("r".toSlice()));
        assertTrue("foobar".toSlice().contains("".toSlice()));
        assertTrue("foobar".toSlice().contains("foobar".toSlice()));
        assertTrue(!"foobar".toSlice().contains("s".toSlice()));
    }

    function testConcat() public {
        assertEq0("foo".toSlice().concat("bar".toSlice()), "foobar");
        assertEq0("".toSlice().concat("bar".toSlice()), "bar");
        assertEq0("foo".toSlice().concat("".toSlice()), "foo");
    }

    function testJoin() public {
        stringsExt.slice[] memory parts = new stringsExt.slice[](4);
        parts[0] = "zero".toSlice();
        parts[1] = "one".toSlice();
        parts[2] = "".toSlice();
        parts[3] = "two".toSlice();

        assertEq0(" ".toSlice().join(parts), "zero one  two");
        assertEq0("".toSlice().join(parts), "zeroonetwo");

        parts = new stringsExt.slice[](1);
        parts[0] = "zero".toSlice();
        assertEq0(" ".toSlice().join(parts), "zero");
    }
}
