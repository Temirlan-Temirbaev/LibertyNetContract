// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./LibertyNetModeration.sol";

contract PostNFT is Moderation, ERC721  {
    uint256 public nextTokenId;
    mapping(uint256 => PostData) public postData;


    struct PostData {
        string content;
        string mediaContentUrl;
        address author;
        uint256 postId;
    }

    constructor() ERC721("LibertyNetPost", "LNPNFT") {
    }

    function getPostsByAuthor(address author) public view returns (PostData[] memory) {
        uint256 count = 0;

        // Count the number of posts by the author
        for (uint256 i = 0; i < nextTokenId; i++) {
            if (postData[i].author == author) {
                count++;
            }
        }

        // Create a storage array with the correct size
        PostData[] memory usersPosts = new PostData[](count);

        // Populate the storage array with posts by the author
        uint256 index = 0;
        for (uint256 i = 0; i < nextTokenId; i++) {
            if (postData[i].author == author) {
                usersPosts[index] = postData[i];
                index++;
            }
        }

        return usersPosts;
    }

    function getPostsByContent(string memory contentSubstring) public view returns (PostData[] memory) {
        uint256 count = 0;

        // Count the number of posts containing the content substring
        for (uint256 i = 0; i < nextTokenId; i++) {
            if (stringContainsSubstring(postData[i].content, contentSubstring)) {
                count++;
            }
        }

        // Create a storage array with the correct size
        PostData[] memory postsWithSubstring = new PostData[](count);

        // Populate the storage array with posts containing the content substring
        uint256 index = 0;
        for (uint256 i = 0; i < nextTokenId; i++) {
            if (stringContainsSubstring(postData[i].content, contentSubstring)) {
                postsWithSubstring[index] = postData[i];
                index++;
            }
        }

        return postsWithSubstring;
    }

    function mintPostNFT(
        string memory content,
        string memory mediaContentUrl,
        uint256 id
    ) external isNotBanned {
        uint256 tokenId = nextTokenId++;
        _safeMint(msg.sender, tokenId);

        postData[tokenId] = PostData(content, mediaContentUrl, msg.sender, id);

    }

    function edit(string memory content, string memory mediaContentUrl, uint256 tokenId) public isNotBanned{
        require(ownerOf(tokenId) != address(0), "Token ID does not exist");
        require(ownerOf(tokenId) == msg.sender, "You don't have permission to edit this post");

        // Update post data
        postData[tokenId].content = content;
        postData[tokenId].mediaContentUrl = mediaContentUrl;
    }

    function stringContainsSubstring(string memory _string, string memory substring) internal view returns (bool) {
        bytes memory stringBytes = bytes(_string);
        bytes memory substringBytes = bytes(substring);
        uint256 substringLength = substringBytes.length;
        uint256 j;
        for (uint256 i = 0; i < stringBytes.length; i++) {
            if (stringBytes[i] == substringBytes[0]) {
                j = 1;
                while ((i + j) < stringBytes.length && j < substringLength) {
                    if (stringBytes[i + j] != substringBytes[j]) {
                        break;
                    }
                    j++;
                }
                if (j == substringLength) {
                    return true;
                }
            }
        }
        return false;
    }
}
