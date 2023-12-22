// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ISubscriptionManager {
    function getSubscriptionEndTime(uint256 tokenId) external view returns (uint256);
    function updateSubscriptionEndTime(uint256 tokenId, uint256 endTime) external;
    function renewSubscription(uint256 tokenId, address owner, uint64 duration, uint256 currentTime) external returns (bool);
    function isSubscriptionActive(uint256 tokenId, address subscriber) external view returns (bool);
}

contract SubscriptionManager is ISubscriptionManager {

    mapping(uint256 => uint256) private _subscriptionEndTimes;

    function getSubscriptionEndTime(uint256 tokenId) public view override returns (uint256) {
        return _subscriptionEndTimes[tokenId];
    }

    function updateSubscriptionEndTime(uint256 tokenId, uint256 endTime) public override {
        _subscriptionEndTimes[tokenId] = endTime;
    }

    function renewSubscription(
        uint256 tokenId,
        address owner,
        uint64 duration,
        uint256 currentTime
    ) public override returns (bool) {
        require(msg.sender == owner, "Caller is not the owner");
        require(getSubscriptionEndTime(tokenId) <= currentTime, "Subscription not expired yet");

        updateSubscriptionEndTime(tokenId, currentTime + duration);

        return true;
    }

    function isSubscriptionActive(uint256 tokenId, address subscriber) external view override returns (bool) {
        return getSubscriptionEndTime(tokenId) > block.timestamp && subscriber == msg.sender;
    }
}
