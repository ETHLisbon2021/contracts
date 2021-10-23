//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

    contract Merkle {
        function verifyProof(bytes32 leaf, bytes32 root, bytes memory proof) public pure returns (bool) {
            bytes32 el;
            bytes32 h = leaf;

            for (uint256 i = 32; i <= proof.length; i += 32) {
                assembly {
                    el := mload(add(proof, i))
                }

                if (h < el) {
                    h = keccak256(abi.encodePacked(h, el));
                } else {
                    h = keccak256(abi.encodePacked(el, h));
                }
            }

            return h == root;
        }
    }