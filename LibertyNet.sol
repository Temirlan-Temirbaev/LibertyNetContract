// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SecureMessage {
    struct User {
        address userAddress;
        bool isModerator;
        bool isBanned;
        uint256 subscriptionCost;
        address[] subscribers;
        Subscription[] subscriptions;
    }

    struct Subscription {
        uint256 cost;
        uint256 startedAt;
        address account;
    }

    struct Post {
        uint256 id;
        address author;
        bool isPublic;
    }

    address private _owner;
    Post[] private posts;
    mapping(address => User) public users;

    constructor(){
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Only owner has access");
        _;
    }

    modifier onlyModerator(){
        require(users[msg.sender].isModerator == true, "Only moderators has access");
        _;
    }

    function changeIsModerator(address user) public onlyOwner {
        users[user].isModerator = !users[user].isModerator;
    }

    function changeBan(address user) public onlyModerator {
        users[user].isBanned = !users[user].isBanned;
    }

    function buySubscription(address payable user) public {
        address payable recipient = payable(users[user].userAddress);
        recipient.transfer(users[user].subscriptionCost);
        Subscription memory newSubscription = Subscription({
            cost: users[user].subscriptionCost,
            startedAt: block.timestamp,
            account: msg.sender
        });

        users[user].subscriptions.push(newSubscription);
    }

    function post(uint256 id, bool isPublic) public {
        posts.push(Post({
            id: id,
            isPublic: isPublic,
            author: msg.sender
        }));
    }

    function getPost(uint256 id) public view returns (Post memory) {
        bool isFound = false;
        for (uint256 i = 0; i < posts.length; i++) {
            if (posts[i].id == id) {
                isFound = true;
                require(users[posts[i].author].isBanned == false, "This post has been banned");
                if (posts[i].isPublic == false) {
                    bool isHasSubscription = false;
                    for (uint256 j = 0; j < users[msg.sender].subscriptions.length; j++) {
                        if (users[msg.sender].subscriptions[j].account == posts[i].author) {
                            isHasSubscription = true;
                            if (users[msg.sender].subscriptions[j].startedAt - block.timestamp > 0) {
                                revert("Your subscription is expired!");
                            }
                        }
                    }
                    require(isHasSubscription == true, "You have not subscription");
                    return posts[i];
                }
                return posts[i];
            }
        }
        require(isFound == true, "Not found");
    }

    function getAuthorsPost(address user) public view returns (Post[] memory) {
        Post[] memory usersPosts = new Post[](posts.length);
        uint256 count = 0;
        for (uint256 i = 0; i < posts.length; i++) {
            Post memory post = getPost(posts[i].id);
            if (post.author == user) {
                usersPosts[count] = post;
                count++;
            }
        }

        Post[] memory result = new Post[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = usersPosts[i];
        }
        return result;
    }

    function getUsers() public view {
        return users[msg.sender];
    }

    function get

}