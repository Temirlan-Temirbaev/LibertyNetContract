// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract LibertyNet {
    struct User {
        string nickname;
        string avatar;
        bool isModerator;
        uint256[] postIds;
        bool isBanned;
        address[] boosters;
    }

    struct Post {
        address author;
        string content;
        string multiMedia;
        uint256[] commentIds;
        bool isPublic;
    }

    struct Comment {
        address authod;
        string content;
    }

    mapping (address => User) private users;
    address private _owner;
    Post[] private posts;
    Comment[] private comments;

    constructor(){
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only owner can call this function");
        _;
    }

    modifier onlyUnBanned() {
        require(users[msg.sender].isBanned == false, "You are banned!");
        _;
    }

    modifier onlyModerator() {
        require(users[msg.sender].isModerator == true, "You have no rights for this operation!");
        _;
    }

    function changeUserData(string memory nickname, string memory avatar) public {
        require(bytes(nickname).length > 0, "Nickname cannot be empty");
        require(bytes(avatar).length > 0, "Avatar cannot be empty");
        users[msg.sender] = User({
            nickname: nickname,
            avatar: avatar,
            isModerator: users[msg.sender].isModerator,
            postIds: users[msg.sender].postIds,
            isBanned: users[msg.sender].isBanned,
            boosters: users[msg.sender].boosters
        });
    }

    function switchIsBanned(address user) public onlyModerator {
        if (users[user].isBanned == true) users[user].isBanned = false;
        else users[user].isBanned = false;
    }

    function switchUserRole(address userAddress, bool newRole) public onlyOwner {
        require(users[userAddress].isBanned == false, "User is banned");
        users[userAddress].isModerator = newRole;
    }

    function createPost(string memory content, string memory multiMedia, bool isPublic) public onlyUnBanned {
        uint256 postId = posts.length;
        posts.push(Post({
            author: msg.sender,
            content: content,
            multiMedia: multiMedia,
            commentIds: new uint256[](0),
            isPublic: isPublic
        }));

        // Update user's postIds
        users[msg.sender].postIds.push(postId);
    }

    function comment(uint256 postId, string memory content) public onlyUnBanned {
        require(postId < posts.length, "Invalid post ID");

        uint256 commentId = comments.length;
        comments.push(Comment({
            authod: msg.sender,
            content: content
        }));

        // Update post's commentIds
        posts[postId].commentIds.push(commentId);
    }

}
