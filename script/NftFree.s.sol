// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/NftFree.sol";

contract NftFreeScript is Script {
	function run() public {
		vm.startBroadcast();
		new NFTFree();
		vm.stopBroadcast();
	}
}
