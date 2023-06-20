// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "src/NftFree.sol";
import "./util/MerkleTreeHelper.sol";

contract NFTFreeTest is MerkleTreeHelper {
	NFTFree public nftContract;

	address public owner;
	MerkleDataSet internal merkleDataset;

	function setUp() public {
		nftContract = new NFTFree();
		merkleDataset = createMerkleDataset(10);
		owner = nftContract.owner();
		vm.startPrank(owner);
		nftContract.setMerkleRoot(merkleDataset.root);
		vm.stopPrank();
	}

	modifier saleStart() {
		vm.startPrank(owner);
		nftContract.setPhase(NFTFree.SalePhase.Presale);
		vm.stopPrank();
		_;
	}

	// =============================================================
	//   UNIT
	// =============================================================

	function testCheckInitValue() public {
		assertEq(nftContract.name(), "MyToken");
		assertEq(nftContract.symbol(), "MTK");
		assertEq(nftContract.owner(), owner);
		assertEq(nftContract.merkleRoot(), merkleDataset.root);
	}

	// access controll
	function testFailtNotOwner() public {
		vm.startPrank(vm.addr(1));
		nftContract.setPhase(NFTFree.SalePhase.Presale);
	}

	// sale
	function testRevertPresaleMintNotStartSale() public {
		bytes32[] memory proof = getProof(merkleDataset.leaves, 0);
		vm.startPrank(vm.addr(1));
		vm.expectRevert("presale event is not active");
		nftContract.presaleMint(10, 10, proof);
	}

	function testRevertPresaleMintNotRoot() external saleStart {
		MerkleDataSet memory anotherMerkleDataset = createMerkleDataset(15);
		vm.startPrank(owner);
		nftContract.setMerkleRoot(anotherMerkleDataset.root);
		vm.stopPrank();
		bytes32[] memory proof = getProof(merkleDataset.leaves, 0);
		vm.startPrank(vm.addr(1));
		vm.expectRevert("you don't have a whitelist");
		nftContract.presaleMint(1, 10, proof);
	}

	function testRevertPresaleMintNotAddress() external saleStart {
		bytes32[] memory proof = getProof(merkleDataset.leaves, 0);
		vm.startPrank(vm.addr(2));
		vm.expectRevert("you don't have a whitelist");
		nftContract.presaleMint(1, 10, proof);
	}

	function testRevertPresaleMintNotProof() external saleStart {
		bytes32[] memory proof = getProof(merkleDataset.leaves, 1);
		vm.startPrank(vm.addr(1));
		vm.expectRevert("you don't have a whitelist");
		nftContract.presaleMint(1, 10, proof);
	}

	function testRevertPresaleMintNotAllowtedAmount() external saleStart {
		bytes32[] memory proof = getProof(merkleDataset.leaves, 0);
		vm.startPrank(vm.addr(1));
		vm.expectRevert("you don't have a whitelist");
		nftContract.presaleMint(1, 15, proof);
	}

	// =============================================================
	//   INTEGRATION
	// =============================================================

	function testSuccessPresaleMint() external saleStart {
		bytes32[] memory proof = getProof(merkleDataset.leaves, 0);
		vm.startPrank(vm.addr(1));
		nftContract.presaleMint(10, 10, proof);
		assertEq(nftContract.balanceOf(vm.addr(1)), 10);

		nftContract.safeTransferFrom(vm.addr(1), vm.addr(2), 1);
		assertEq(nftContract.balanceOf(vm.addr(1)), 9);
		assertEq(nftContract.balanceOf(vm.addr(2)), 1);

		vm.expectRevert("exceeds number of earned tokens");
		nftContract.presaleMint(10, 10, proof);
		vm.stopPrank();
	}
}
