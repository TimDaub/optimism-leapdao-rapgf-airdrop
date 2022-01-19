// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";
import {StateTree, DEPTH} from "indexed-sparse-merkle-tree/StateTree.sol";

function getHolders() pure returns (address[31] memory) {
  return [
    address(0x8db6B632D743aef641146DC943acb64957155388),
    0x8AB21C65041778DFc7eC7995F9cDef3d5221a5ad,
    0xaf0939af286A35DBfab7DEd7c777A5F6E8BE26A8,
    0xBbdDEeA2044b05F1B950cC311F31De6371B0c186,
    0xDF708717070981a8097912318C722F19eEFb3BEf,
    0xB121b3DdaA9af45Df9878C855079F8A78eea9772,
    0x24F861f8356fa8d18b6Adea07Ac59719f42012B1,
    0x3b528d4aB08EF019972E6bD7f40D55ab35c0846b,
    0x5B4dF17CA5A3339D722028a585582693742E5B5a,
    0x41C3Fa96942d19043450Ec963EB4DF44336d8035,
    0xD2FA59811af055e0e94D570EA7F9800c0E5C0428,
    0xBbebEa9812971a5C2B7d99a99E7d8b4d5Fda7091,
    0x0e814C57Bd80D0835a3b7d13B079A0590E3d287D,
    0x51baB87c42d384d1cD3056d52D97C84ddaa65fe4,
    0x62817523F3B94182B9DF911a8071764F998f11a4,
    0xF9Cd23BCD16D5F2B79c99280BEa040ef70C3990C,
    0xD0A450259B8afb25D4d7e836D3BfFd806b70d4e5,
    0x89AB6D3C799d35f5b17194Ee7F07253856A67949,
    0xF33e3693beBDE7941A326008DE3a11Da90Ac8159,
    0x4A3343a2a36eEbE0cA9160F0974f3cf0A2B36Ec5,
    0x9523D191A1b72F186B0377ef6053CDc5181C7e3C,
    0xc97f82c80DF57c34E84491C0EDa050BA924D7429,
    0x9293Edf664DF484598DDE9bFbFdb558028BF417f,
    0x2858b141429244dDA03354AA35F1Cc761a058a34,
    0xa8733EA0bD8334C74Df668933bE72393Df392Eb6,
    0x527621278422FFf45A66f7086bAeAC770CF12b69,
    0x000001f568875F378Bf6d170B790967FE429C81A,
    0xD0A450259B8afb25D4d7e836D3BfFd806b70d4e5,
    0x9A8A9958ac1B70c49ccE9693CCb0230f13F63505,
    0x4e764a1d088D4dbdC5566C164deC2C14fb0ded13,
    0x901442E4dEeC484E9B2EFDb2bA20FCb19880D9A3
  ];
}
function getShares() pure returns (uint16[31] memory) {
  return [uint16(1973),
    1555,
    1276,
     927,
     474,
     446,
     396,
     368,
     348,
     323,
     250,
     235,
     166,
     163,
     156,
     102,
     92,
     81,
     69,
     68,
     66,
     65,
     60,
     60,
     52,
     45,
     31,
     30,
     29,
     28,
     16
 	];
}

contract ComputeRoot is DSTest {
    function buildLeaveBase() public pure returns (bytes32[] memory) {
			bytes32[] memory hashes = new bytes32[](2**DEPTH);
			address[31] memory holders = getHolders();
			uint16[31] memory shares = getShares();

      assert(holders.length == shares.length);
      for(uint i = 0; i < holders.length; i++) {
        hashes[i] = keccak256(abi.encode(holders[i], shares[i]));
      }
      return hashes;
    }

    function testBuildLeaveBase() public {
			bytes32[] memory nextHashes = buildLeaveBase();
      assertEq(nextHashes[31], 0);
    }

    function buildLeaveLevel(uint level) public pure returns (bytes32[] memory) {
      require(level <= 7, "level above 7");
			bytes32[] memory nextHashes = buildLeaveBase();
			bytes32[] memory prevHashes = new bytes32[](2**DEPTH);

      for (uint d = DEPTH-1; d > level; d--) {
        prevHashes = nextHashes;
			  nextHashes = new bytes32[](2**d);

        if (d != 0) {
          for (uint i = 0; i < nextHashes.length - 1; i += 2) {
            nextHashes[i/2] = StateTree.hash(prevHashes[i], prevHashes[i+1]);
          }
        } else {
          assert(prevHashes.length == 2);
          nextHashes[0] = StateTree.hash(prevHashes[0], prevHashes[1]);
        }
      }
      return nextHashes;
    }

    function testBuildLeaveLevel() public {
      bytes32[] memory hashes0 = buildLeaveLevel(6);
      assertEq(hashes0.length, 128);
      assertEq(hashes0[64], 0);
      assertEq(hashes0[127], 0);

      bytes32[] memory hashes1 = buildLeaveLevel(5);
      assertEq(hashes1.length, 64);
      assertEq(hashes1[0], StateTree.hash(hashes0[0], hashes0[1]));
      assertEq(hashes1[32], 0);
      assertEq(hashes1[63], 0);

      bytes32[] memory hashes2 = buildLeaveLevel(4);
      assertEq(hashes2.length, 32);
      assertEq(hashes2[16], 0);
      assertEq(hashes2[31], 0);

      bytes32[] memory hashes3 = buildLeaveLevel(3);
      assertEq(hashes3.length, 16);
      assertEq(hashes3[8], 0);
      assertEq(hashes3[15], 0);

      bytes32[] memory hashes4 = buildLeaveLevel(2);
      assertEq(hashes4.length, 8);
      assertEq(hashes4[4], 0);
      assertEq(hashes4[7], 0);

      bytes32[] memory hashes5 = buildLeaveLevel(1);
      assertEq(hashes5.length, 4);
      assertEq(hashes4[2], 0);
      assertEq(hashes4[3], 0);

      bytes32[] memory hashes6 = buildLeaveLevel(0);
      assertEq(hashes6.length, 2);
      assertEq(hashes4[1], 0);
    }

    function testBuildRootHash() public {
      bytes32[] memory nextHashes = buildLeaveLevel(0);
      assertEq(nextHashes.length, 2);
      assertEq(StateTree.hash(nextHashes[0], nextHashes[1]), 0x3631a9f12a834d6eef89942c17fe7e394cf07f1d5b1cdce3fd8c04521de8b73b);
    }

    function testInclusionOfFirstMember() public {
			bytes32[] memory level0 = buildLeaveBase();
			bytes32[] memory level1 = buildLeaveLevel(6);
			bytes32[] memory level2 = buildLeaveLevel(5);
			bytes32[] memory level3 = buildLeaveLevel(4);
			bytes32[] memory level4 = buildLeaveLevel(3);
			bytes32[] memory level5 = buildLeaveLevel(2);
			bytes32[] memory level6 = buildLeaveLevel(1);
			bytes32[] memory level7 = buildLeaveLevel(0);

      bytes32[] memory proofs = new bytes32[](5);
      proofs[0] = level0[1];
      proofs[1] = level1[1];
      proofs[2] = level2[1];
      proofs[3] = level3[1];
      proofs[4] = level4[1];
      assertEq(level5[1], 0);

      uint8 value = StateTree.bitmap(0);
      value += StateTree.bitmap(1);
      value += StateTree.bitmap(2);
      value += StateTree.bitmap(3);
      value += StateTree.bitmap(4);

      uint index = 0;
      bytes32 leaf = level0[0];
      bytes32 ROOT = 0x3631a9f12a834d6eef89942c17fe7e394cf07f1d5b1cdce3fd8c04521de8b73b;
      assertEq(StateTree.compute(proofs, value, index, leaf), ROOT);
      assertTrue(StateTree.validate(proofs, value, index, leaf, ROOT));
    }

}
