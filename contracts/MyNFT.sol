// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyNFT is ERC721 {
    bytes32 public immutable merkleRoot;
    uint256 public nextTokenId;
    mapping(address => bool) public hasClaimed;

    error AlreadyClaimed();
    /// @notice Thrown if address/amount are not part of Merkle tree
    error NotInMerkle();

    event Claim(address indexed to, uint256 nextTokenId);

    constructor(bytes32 _merkleRoot) ERC721("MyNFT", "NFT") {
        merkleRoot = _merkleRoot;
    }

    function toBytes32(address addr) internal pure returns (bytes32) {
        return bytes32(uint256(uint160(addr)));
    }

    function mint(bytes32[] calldata merkleProof) public payable {
        if (hasClaimed[msg.sender]) revert AlreadyClaimed();

        bool isValidLeaf = MerkleProof.verify(
            merkleProof,
            merkleRoot,
            toBytes32(msg.sender)
        );
        if (!isValidLeaf) revert NotInMerkle();

        hasClaimed[msg.sender] = true;

        nextTokenId++;
        _mint(msg.sender, nextTokenId);
        emit Claim(msg.sender, nextTokenId);
    }
}
