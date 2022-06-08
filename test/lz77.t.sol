// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/test.sol";


import {LZ77Lib} from '../src/LZ77Lib.sol';


contract lz77Test is DSTest {
    using LZ77Lib for *;

    function testLZ77CompressShort() public {

        //string memory stringToCompress = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus sed tempor magna. Curabitur at lobortis sem. Aliquam pretium, nunc ut consectetur venenatis, enim augue rutrum nibh, vitae iaculis est augue ut est. Praesent vehicula lacinia enim in faucibus. Maecenas quis porttitor nisi.In dolor orci, auctor ut cursus vitae, dignissim vitae ante. Nulla nec lorem commodo, vehicula massa a, vulputate mi.Pellentesque nibh nibh, bibendum quis vestibulum sit amet, vulputate convallis turpis. Integer non ornare purus.Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Maecenas in tortor sed enim condimentum rhoncus a eu orci. Vivamus odio lorem, tincidunt eget nisi ac, venenatis interdum neque. Aliquam quis neque a dui efficitur pellentesque vitae eu augue. Nulla at tempus magna. In augue orci, vehicula non imperdiet a, sagittis vitae massa. Duis ultricies ante nisi, eget dignissim lorem lacinia sit amet. Nullam luctus, diam eget elementum bibendum, ex odio rhoncus est, eu congue orci enim non tortor. Vestibulum non diam at lorem tincidunt rutrum sit amet sit amet leo. Mauris lorem risus, fermentum vitae eros ut, mollis faucibus sapien. Nullam sed mauris mi. Vivamus sit amet metus pharetra, ultricies ligula a, pellentesque nibh. Mauris eget tortor massa. Phasellus et quam vitae erat posuere pulvinar at et nunc. Fusce est erat, aliquam hendrerit congue eu, egestas eget turpis. Nunc vel eros ac lectus interdum ullamcorper nec id dui. Phasellus ut velit euismod, malesuada lacus quis, porta nisi. Sed ultricies lorem id lorem iaculis, a sodales mi semper. Proin feugiat justo ut urna commodo, rutrum mattis sem tincidunt. Donec condimentum a urna sit amet blandit. Sed lorem leo, ullamcorper sit amet feugiat ac, elementum eu lorem. Suspendisse tristique interdum ex, ut laoreet lacus gravida vel. Nullam varius cursus volutpat. Aenean pellentesque orci aliquet posuere pellentesque. Vestibulum in enim sed sapien tincidunt mollis nec et nunc metus.";
        bytes memory stringToCompress = abi.encodePacked("simple test simple test");

        bytes memory compressedString = stringToCompress.compress();

        emit log_string(string(compressedString));
        emit log_bytes(compressedString);

        bytes memory expectedResult = abi.encodePacked(hex"00007300006900006D00007000006C0000650000200000740000650000730000740000200CB000");

        assertEq0(abi.encodePacked(compressedString), expectedResult);

    }

    function testLZ77CompressLong() public {

        bytes memory stringToCompress = abi.encodePacked("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus sed tempor magna. Curabitur at lobortis sem. Aliquam pretium, nunc ut consectetur venenatis, enim augue rutrum nibh, vitae iaculis est augue ut est. Praesent vehicula lacinia enim in faucibus. Maecenas quis porttitor nisi.In dolor orci, auctor ut cursus vitae, dignissim vitae ante. Nulla nec lorem commodo, vehicula massa a, vulputate mi.Pellentesque nibh nibh, bibendum quis vestibulum sit amet, vulputate convallis turpis. Integer non ornare purus.Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Maecenas in tortor sed enim condimentum rhoncus a eu orci. Vivamus odio lorem, tincidunt eget nisi ac, venenatis interdum neque. Aliquam quis neque a dui efficitur pellentesque vitae eu augue. Nulla at tempus magna. In augue orci, vehicula non imperdiet a, sagittis vitae massa. Duis ultricies ante nisi, eget dignissim lorem lacinia sit amet. Nullam luctus, diam eget elementum bibendum, ex odio rhoncus est, eu congue orci enim non tortor. Vestibulum non diam at lorem tincidunt rutrum sit amet sit amet leo. Mauris lorem risus, fermentum vitae eros ut, mollis faucibus sapien. Nullam sed mauris mi. Vivamus sit amet metus pharetra, ultricies ligula a, pellentesque nibh. Mauris eget tortor massa. Phasellus et quam vitae erat posuere pulvinar at et nunc. Fusce est erat, aliquam hendrerit congue eu, egestas eget turpis. Nunc vel eros ac lectus interdum ullamcorper nec id dui. Phasellus ut velit euismod, malesuada lacus quis, porta nisi. Sed ultricies lorem id lorem iaculis, a sodales mi semper. Proin feugiat justo ut urna commodo, rutrum mattis sem tincidunt. Donec condimentum a urna sit amet blandit. Sed lorem leo, ullamcorper sit amet feugiat ac, elementum eu lorem. Suspendisse tristique interdum ex, ut laoreet lacus gravida vel. Nullam varius cursus volutpat. Aenean pellentesque orci aliquet posuere pellentesque. Vestibulum in enim sed sapien tincidunt mollis nec et nunc metus.");

        bytes memory compressedString = stringToCompress.compress();

        emit log_uint(compressedString.length);

        bytes memory expectedResult = abi.encodePacked(hex"00004c00006f00007200006500006d00002000006900007000007300007500006d00002000006400006f00006c00006f00007200002000007300006900007400002000006100006d00006500007400002c00002000006300006f00006e00007300006500006300007400006500007400007500007200002000006100006400006900007000006900007300006300006900006e00006700002000006500006c00006900007400002e00002000005600006900007600006100006d00007500007300002000007300006500006400002000007400006500006d0000703a406100006700006e00006100002e00002000004300007500007200006100006200006935602000006c00006f00006200006f00007200007400006928502e00002000004100006c00006900007100007500006100006d00002000007000007200006500007400006900007500006d00002c00002000006e00007500006e0000630000200000750000746be06500006e00006500006e00006134402000006500006e00006900006d000020000061000075000067000075000065000020000072000075000074000072a4406900006200006800002c00002000007600006900007400006100006500002000006900006100006300007500006c5b4073b240672540740d502000005000007200006100006500007300006500006e0000744c406925402000006c000061bc406152706e00002000006600006100007500006300006900006200007500007300002e00002000004d0000610000650000637040200000710000754c406f000072000074000074000069000074ce406900007300006900002e00004900006e16817200006300006900002c6640740d4074000020000063000075000072000073fe40698940200000640000690000672f406900006d9a806e00007400006500002e00002000004e00007500006c7a406500006306416500006de5406d00006f00006400006fbf406896706100007300007300006100002000006112406c00007000007500007400006100007400006500002000006d00006900002e00005000006500006c00006cbd4073000071d34069000062000068f6806900006200006500006e000064054175aa4065000073000074c2407500006db3c17548906f00006e00007600006100006c1f5175000072bb4120000049534065d9406ecf40610000720000650000200000700000750000720341654aa06e3b40700e527200006900006d3e406e2ca16f05416c04417300002000006500007400002000007500006c0000740000720000690000630000653551750000654f407500006200006900006c6541758041205aa16e00002037416f5d426483716f00006e00006400006900006de6406d00002000007200006800006f00006e0000635340200000650000756460205e926400006900006f3e712000007400006900006e000063000069000064000075d641677e40690000730000690000200000610000634e5165306269be406426527100007581416c6f72751d40654f5120000064000075000069000020000065000066000066000069000063a362656cc169bd51754e7220c17174e16273e1926e6f8272155265ce816f00006e00002000006900006d0000708340659141200000730000610000670000694e4220597061ee41200000448e506c3c5165f64074e65169ef42650000744cc26f365261ba7269e571209760208971200000640000690d40673b406c0000655381692b7220000065000078457168657173274275815175c3706592516fa6912012c26f0343611b42209170698891759463699a707309906500006f595372ea406f3550692f4320000066000065000072a280696c616f0c412c00002000006d00006fac62616b826100007000006900006500006eeca0650000643f41722340697dc474717065945268d542727a416c5f91690000679c512cebf169000062000068a3a06743406fa26261a56168000061000073304073e95275834069b17074f0a27500006c0000760000694943617c4120cd54200000460000750000730000632840742c602000006185826500006e000064000072000065000072b2406f7b6175f26174224367825072a9637515456500006c1e71634f41748a406edf826c14416f0000726b426e5f4464d65220b5b07441507465407375442000006d00006100006c0000650000730000750000610000640b6573146320ef5420eb645364416c38a1721956200980636c55208942644c506d000069d5556530427200006f2854750000670000690b417500007300007400006f83507200006e000061f6b4752e62611363654ac22000004400006fc9506f16b4203f6069e3816c0000611d402ea8606f1b636feb51610d91692d80658b7063644165538075397020000053000075000073000070904173000073000065000020f24074a4412061a17858402000006c0000612e407432817200006100007600006940416500006c98a2610000720000691b40750e766c000075000074000070000061a4406500006e00006500006100006e73f2726b436c6a502043a26c22a02078c36e9773650000640d837479a36f2e636500006378926d025300");

        assertEq0(abi.encodePacked(compressedString), expectedResult);

    }

    
    function setUp() public {}

    
}
