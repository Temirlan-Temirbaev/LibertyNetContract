// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract PostNFT is ERC721 {
    uint256 public nextTokenId;
    address private owner;

    struct PostData {
        string content;
        string mediaContentUrl;
        address author;
    }

    mapping(uint256 => PostData) public postData;

    address[] blackList;
    address[] moderators;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    modifier onlyModerator() {
        bool isModerator = false;
        for (uint256 i = 0; i < moderators.length; i++) {
            if (moderators[i] == msg.sender) {
                isModerator = true;
            }
        }
        require(isModerator == true, "You have no rights to this function");
        _;
    }

    constructor() ERC721("LibertyNetPost", "LNPNFT") {
        owner = msg.sender;
    }

    function addToModerators(address userAddress) public onlyOwner {
        moderators.push(userAddress);
    }

    function addToBlackList(address userAddress) public onlyModerator {
        blackList.push(userAddress);
    }

    function mintPostNFT(
        string memory content,
        string memory mediaContentUrl
    ) external {
        for (uint256 i = 0; i < blackList.length; i++) {
            if (blackList[i] == msg.sender) {
                revert("You are banned");
            }
        }
        uint256 tokenId = nextTokenId++;
        _safeMint(msg.sender, tokenId);
        postData[tokenId] = PostData(content, mediaContentUrl, msg.sender);
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


}