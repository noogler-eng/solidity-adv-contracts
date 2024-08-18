//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import "./node_modules/solmate/src/tokens/ERC721.sol";
import "./node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./node_modules/@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract secureSoulBoundToken{
    using MerkleProof for bytes32[];

    struct TokenData {
        string publicData;
        bytes32 privateDataHash;
    }

    error UnauthorisedError();
    error InvalidProof();
    error TransferSoulBound();

    mapping(uint256 => TokenData) private _tokenData;
    mapping(uint256 => mapping(address => bool)) private _accessPermissions;
    uint256 private _tokenIdCounter = 0;


    constructor() ERC721("secureSolBound", "SSB") {}

    // Mint a new token with associated data
    function mintToken(address recipient, string calldata publicData, bytes32 privateDataHash) external onlyOwner {
        require(recipient != address(0), 'there should be valid address');
        uint256 tokenId = _tokenIdCounter++;
        _mint(recipient, tokenId);
        _tokenData[tokenId] = TokenData(publicData, privateDataHash);
    }

    // Grant access to private data
    function grantAccess(uint256 tokenId, address user) external {
        require(user != address(0), 'there should be valid address');
        require(ownerOf(tokenId) == msg.sender, "Only token owner can grant access");
        _accessPermissions[tokenId][user] = true;
    }

    // Revoke access to private data
    function revokeAccess(uint256 tokenId, address user) external {
        require(user != address(0), 'there should be valid address');
        require(ownerOf(tokenId) == msg.sender, "Only token owner can revoke access");
        _accessPermissions[tokenId][user] = false;
    }

    // View public data
    function viewPublicData(uint256 tokenId) external view returns (string memory) {
        return _tokenData[tokenId].publicData;
    }

    // Verify and view private data (ZKP or Merkle Proof would be used in actual implementation)
    function verifyAndAccessPrivateData(uint256 tokenId, bytes32[] calldata proof, bytes32 leaf) external view returns (bool) {
        if (_accessPermissions[tokenId][msg.sender] || ownerOf(tokenId) == msg.sender) {
            bytes32 root = _tokenData[tokenId].privateDataHash;
            if (MerkleProof.verify(proof, root, leaf)) {
                return true;
            } else {
                revert InvalidProof();
            }
        } else {
            revert UnauthorizedAccess();
        }
    }

    // Override transfer function to make tokens soulbound
    // no transfer allowed of token, only access can be given for certain time
    function transferFrom(address from, address to, uint256 tokenId) public override {
        revert TransferSoulbound();
    }
}