// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./SubscriptionManager.sol";
import "./LibertyNetPost.sol";

contract SocialMediaSubscription is ERC721Enumerable, Ownable {
    ISubscriptionManager private _subscriptionManager;
    PostNFT private _postNFT;

    mapping(uint256 => uint64) private _subscriptionDurations;
    mapping(uint256 => uint256) private _subscriptionPrices;
    mapping(uint256 => uint256) private _totalSubscriptions;

    uint256 private constant OWNER_PERCENTAGE = 3;

    constructor(
        string memory name_,
        string memory symbol_,
        address postNFTAddress
    ) ERC721(name_, symbol_) Ownable(msg.sender) {
        _subscriptionManager = new SubscriptionManager();
        _postNFT = PostNFT(postNFTAddress);
    }

    modifier postExists(uint256 tokenId) {
        require(ownerOf(tokenId) != address(0), "Invalid post ID");
        _;
    }


    function setSubscriptionDuration(uint256 tokenId, uint64 duration) external postExists(tokenId) {
        require(duration == 30 || duration == 90 || duration == 180 || duration == 365, "Invalid duration");
        require(!_subscriptionManager.isSubscriptionActive(tokenId, ownerOf(tokenId)), "Subscription already active");

        _subscriptionDurations[tokenId] = duration;
    }


    function getSubscriptionDuration(uint256 tokenId) external view postExists(tokenId) returns (uint64) {
        return _subscriptionDurations[tokenId];
    }

    function setSubscriptionPrice(uint256 tokenId, uint256 newPrice) external postExists(tokenId) {
        require(_postNFT.ownerOf(tokenId) == msg.sender, "Only the post author can set the subscription price");
        _subscriptionPrices[tokenId] = newPrice;
    }

    function purchaseSubscription(uint256 tokenId, uint256 level, uint64 duration) external payable postExists(tokenId) {
        require(msg.value >= _subscriptionPrices[tokenId] * level, "Insufficient payment");
        require(!_subscriptionManager.isSubscriptionActive(tokenId, ownerOf(tokenId)), "Subscription already active");

        bool renewed = _subscriptionManager.renewSubscription(tokenId, ownerOf(tokenId), duration, block.timestamp);

        if (renewed) {
            _totalSubscriptions[tokenId]++;
            _transferFundsToOwner(msg.value);
        }
    }

    function getUserSubscriptions() external view returns (uint256[] memory) {
        uint256[] memory subscriptions = new uint256[](balanceOf(msg.sender));
        uint256 count = 0;

        for (uint256 i = 0; i < totalSupply(); i++) {
            uint256 tokenId = tokenByIndex(i);
            if (_subscriptionManager.isSubscriptionActive(tokenId, msg.sender)) {
                subscriptions[count] = tokenId;
                count++;
            }
        }

        assembly {
            mstore(subscriptions, count)
        }

        return subscriptions;
    }

    function _getSubscriptionDuration(uint256 tokenId, uint256 level) internal view returns (uint64) {
        require(level >= 1 && level <= 4, "Invalid subscription level");
        return _subscriptionDurations[tokenId] * uint64(level);
    }

    function _transferFundsToOwner(uint256 amount) internal {
        uint256 ownerAmount = amount * OWNER_PERCENTAGE / 100;
        payable(owner()).transfer(ownerAmount);
    }

    function checkSubscriptionStatus(uint256 tokenId) external view postExists(tokenId) returns (bool) {
        return _subscriptionManager.isSubscriptionActive(tokenId, ownerOf(tokenId));
    }
}
