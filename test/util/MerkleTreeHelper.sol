// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "forge-std/Test.sol";
import "murky/Merkle.sol";

abstract contract MerkleTreeHelper is Test, Merkle {
	struct MerkleDataSet {
		address[] accounts;
		uint256[] units;
		bytes32[] leaves;
		bytes32 root;
	}

	function generateMerkleData(
		address[] memory addresses,
		uint256[] memory units
	) public pure returns (bytes32[] memory leaves) {
		leaves = new bytes32[](addresses.length);
		for (uint256 i = 0; i < addresses.length; i++) {
			leaves[i] = keccak256(abi.encodePacked(addresses[i], units[i]));
		}
		return leaves;
	}

	function createMerkleDataset(uint256 size) internal pure returns (MerkleDataSet memory) {
		address[] memory accounts;
		uint256[] memory units;
		bytes32[] memory leaves;
		bytes32 root;
		accounts = new address[](size);
		units = new uint256[](size);

		for (uint256 i = 0; i < accounts.length; i++) {
			accounts[i] = vm.addr(i + 1);
			units[i] = size + i;
		}

		leaves = generateMerkleData(accounts, units);
		root = getRoot(leaves);
		return MerkleDataSet(accounts, units, leaves, root);
	}
}
