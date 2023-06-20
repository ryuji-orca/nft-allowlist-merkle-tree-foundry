// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "src/NftPayable.sol";
import "murky/Merkle.sol";
import "./util/MerkleTreeHelper.sol";

contract NFTPayableTest is MerkleTreeHelper {
	NFTPayable public nftContract;

	uint256 public mintCost;

	address public owner;

	MerkleDataSet internal merkleDataset;

	function setUp() public {
		nftContract = new NFTPayable();
		merkleDataset = createMerkleDataset(10);
		owner = nftContract.owner();
		mintCost = nftContract.mintCost();
		vm.startPrank(owner);
		nftContract.setMerkleRoot(merkleDataset.root);
		vm.stopPrank();
		vm.deal(address(vm.addr(1)), 1 ether);
		vm.deal(address(vm.addr(2)), 1 ether);
	}

	modifier saleStart() {
		vm.startPrank(owner);
		nftContract.setPhase(NFTPayable.SalePhase.Presale);
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
		assertEq(nftContract.mintCost(), mintCost);
		assertEq(nftContract.withdrawAddress(), 0x9b6D593a06d4DA6EEe0213b105451617f09bD063);
		assertEq(nftContract.merkleRoot(), merkleDataset.root);
	}

	// access controll
	function testFailtNotOwner() public {
		vm.startPrank(vm.addr(1));
		nftContract.setPhase(NFTPayable.SalePhase.Presale);
	}

	// sale
	function testRevertPresaleMintNotStartSale() public {
		bytes32[] memory proof = getProof(merkleDataset.leaves, 0);
		vm.startPrank(vm.addr(1));
		vm.expectRevert("presale event is not active");
		nftContract.presaleMint(10, 10, proof);
	}

	function testRevertPresaleMintNotEnoughEth() public saleStart {
		bytes32[] memory proof = getProof(merkleDataset.leaves, 0);
		vm.startPrank(vm.addr(1));
		vm.expectRevert("not enough eth");
		nftContract.presaleMint{ value: mintCost }(10, 10, proof);
	}

	function testRevertPresaleMintNotRoot() public saleStart {
		MerkleDataSet memory anotherMerkleDataset = createMerkleDataset(15);
		vm.startPrank(owner);
		nftContract.setMerkleRoot(anotherMerkleDataset.root);
		vm.stopPrank();
		bytes32[] memory proof = getProof(merkleDataset.leaves, 0);
		vm.startPrank(vm.addr(1));
		vm.expectRevert("you don't have a whitelist");
		nftContract.presaleMint{ value: mintCost * 10 }(1, 10, proof);
	}

	function testRevertPresaleMintNotAddress() public saleStart {
		bytes32[] memory proof = getProof(merkleDataset.leaves, 0);
		vm.startPrank(vm.addr(2));
		vm.expectRevert("you don't have a whitelist");
		nftContract.presaleMint{ value: mintCost * 10 }(1, 10, proof);
	}

	function testRevertPresaleMintNotProof() public saleStart {
		bytes32[] memory proof = getProof(merkleDataset.leaves, 1);
		vm.startPrank(vm.addr(1));
		vm.expectRevert("you don't have a whitelist");
		nftContract.presaleMint{ value: mintCost * 10 }(1, 10, proof);
	}

	function testRevertPresaleMintNotAllowtedAmount() public saleStart {
		bytes32[] memory proof = getProof(merkleDataset.leaves, 0);
		vm.startPrank(vm.addr(1));
		vm.expectRevert("you don't have a whitelist");
		nftContract.presaleMint{ value: mintCost * 15 }(1, 15, proof);
	}

	// =============================================================
	//   INTEGRATION
	// =============================================================

	function testPresaleMintSuccessAndError() public saleStart {
		bytes32[] memory proof = getProof(merkleDataset.leaves, 0);
		vm.startPrank(vm.addr(1));
		nftContract.presaleMint{ value: mintCost * 10 }(10, 10, proof);
		assertEq(nftContract.balanceOf(vm.addr(1)), 10);

		nftContract.safeTransferFrom(vm.addr(1), vm.addr(2), 1);
		assertEq(nftContract.balanceOf(vm.addr(1)), 9);
		assertEq(nftContract.balanceOf(vm.addr(2)), 1);

		vm.expectRevert("exceeds number of earned tokens");
		nftContract.presaleMint{ value: mintCost * 10 }(10, 10, proof);
		vm.stopPrank();
	}

	function testWithdrawSuccess() public saleStart {
		bytes32[] memory proof = getProof(merkleDataset.leaves, 0);
		address withdrawAddress = nftContract.withdrawAddress();

		vm.startPrank(vm.addr(1));
		nftContract.presaleMint{ value: mintCost * 10 }(10, 10, proof);
		vm.stopPrank();

		assertEq(mintCost * 10, address(nftContract).balance);
		assertEq(0, withdrawAddress.balance);

		vm.startPrank(owner);
		nftContract.withdraw();
		vm.stopPrank();

		assertEq(0, address(nftContract).balance);
		assertEq(mintCost * 10, withdrawAddress.balance);
	}
}
