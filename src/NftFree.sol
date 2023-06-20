// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "erc721a/contracts//ERC721A.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTFree is ERC721A("MyToken", "MTK"), Ownable {
	enum SalePhase {
		Locked,
		Presale
	}

	SalePhase public phase = SalePhase.Locked;

	bytes32 public merkleRoot;

	mapping(address user => uint256 mintAmount) public presaleMintCount;

	// =============================================================
	//   ONLY OWNER
	// =============================================================

	function setPhase(SalePhase _phase) external onlyOwner {
		phase = _phase;
	}

	function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
		merkleRoot = _merkleRoot;
	}

	// =============================================================
	//   MINT FUNCTION
	// =============================================================

	function presaleMint(uint256 _mintAmount, uint256 _maxMintAmount, bytes32[] calldata _proof) external {
		require(phase == SalePhase.Presale, "presale event is not active");

		require(isWhitelisted(msg.sender, _maxMintAmount, _proof), "you don't have a whitelist");

		require(presaleMintCount[msg.sender] + _mintAmount <= _maxMintAmount, "exceeds number of earned tokens");

		presaleMintCount[msg.sender] += _mintAmount;

		_mint(msg.sender, _mintAmount);
	}

	// =============================================================
	//   MERKLE TREE
	// =============================================================

	function isWhitelisted(
		address _address,
		uint256 _maxMintAmount,
		bytes32[] calldata _proof
	) public view returns (bool) {
		bytes32 leaf = keccak256(abi.encodePacked(_address, _maxMintAmount));
		return MerkleProof.verifyCalldata(_proof, merkleRoot, leaf);
	}

	function _startTokenId() internal view virtual override returns (uint256) {
		return 1;
	}
}
