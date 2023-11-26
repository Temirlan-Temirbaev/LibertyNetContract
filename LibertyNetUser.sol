// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract UserNFT is ERC721 {
    uint256 public nextTokenId;
    address public owner;

    struct UserData {
        address userAddress;
        string nickname;
        string avatar;
    }

    mapping(uint256 => UserData) public userData;

    function mintUserNFT( string memory nickname, string memory avatar) public {
        uint256 tokenId = nextTokenId++;
        _safeMint(msg.sender, tokenId);
        userData[tokenId] = UserData(msg.sender, nickname, avatar);
    }

    constructor() ERC721("LibertyNetUser", "LNUNFT") {
    }

}
