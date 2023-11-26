// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC4907.sol";

contract PostNFT is ERC4907 {
    uint256 public nextTokenId;
    address private owner;

    struct PostData {
        string content;
        string mediaContentUrl;
        address author;
        uint256 subCost;
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

    constructor() ERC4907("LibertyNetPost", "LBPNFT") {
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
        string memory mediaContentUrl,
        uint256 cost
    ) external {
        for (uint256 i = 0; i < blackList.length; i++) {
            if (blackList[i] == msg.sender) {
                revert("User is banned");
            }
        }
        uint256 tokenId = nextTokenId++;
        _safeMint(msg.sender, tokenId);
        _users[tokenId] = UserInfo(msg.sender, block.timestamp + 30 days);
        postData[tokenId] = PostData(content, mediaContentUrl, msg.sender, cost);
    }

    function transferWithUpdateUser(address from, address to, uint256 tokenId, address newUser, uint64 expires) public onlyOwner {
        require(ownerOf(tokenId) == from, "Not the token owner");
        require(to != address(0), "Cannot transfer to the zero address");
        require(!_isTokenExpired(tokenId), "Token is expired");

        delete _users[tokenId];
        _safeTransfer(from, to, tokenId, "");
        _users[tokenId] = UserInfo(newUser, expires);

        emit UpdateUser(tokenId, newUser, expires);
    }

    function rentPost(uint256 tokenId) payable public {
        if (postData[tokenId].subCost < msg.value) revert("You have no money to buy subscription");
        _approve(msg.sender, tokenId, postData[tokenId].author);

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

    function stringContainsSubstring(string memory _string, string memory substring) internal pure returns (bool) {
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
