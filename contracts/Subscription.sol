// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "./SubscriptionManager.sol";

contract SocialMediaSubscription is ERC721Enumerable, Ownable {

    ISubscriptionManager private _subscriptionManager;

    mapping(uint256 => uint256) private _subscriptionPrices;

    mapping(uint256 => uint64) private _subscriptionDurations;

    mapping(uint256 => uint256) private _totalSubscriptions;

    uint256 private constant OWNER_PERCENTAGE = 3;

    struct SubscriptionParams {
        uint64 duration;
        uint256 price;
    }

    mapping(uint256 => SubscriptionParams) private _subscriptionParams;

    event PostCreated(uint256 indexed tokenId, string tokenURI, uint64 duration, uint256 price);

    constructor(string memory name_, string memory symbol_)
    ERC721(name_, symbol_)
    Ownable(msg.sender)
    {
        _subscriptionManager = new SubscriptionManager();
    }

    modifier onlyContractOwner() {
        require(_msgSender() == owner(), "Caller is not the contract owner");
        _;
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _exists(tokenId);
    }

    /**
     * @dev Set the subscription price and duration for a post.
     * @param tokenId The ID of the post (NFT).
     * @param duration The duration of the subscription in seconds.
     * @param price The price of the subscription in ETH.
     */
    function setSubscriptionPriceAndDuration(
        uint256 tokenId,
        uint64 duration,
        uint256 price
    ) external onlyContractOwner {
        _subscriptionPrices[tokenId] = price;
        _subscriptionDurations[tokenId] = duration;
    }

    /**
     * @dev Get the subscription price for a post.
     * @param tokenId The ID of the post (NFT).
     * @return The price of the subscription in ETH.
     */
    function getSubscriptionPrice(uint256 tokenId) external view returns (uint256) {
        return _subscriptionPrices[tokenId];
    }

    /**
     * @dev Get the subscription end time for a post.
     * @param tokenId The ID of the post (NFT).
     * @return The end time of the subscription in seconds.
     */
    function getSubscriptionEndTime(uint256 tokenId) external view returns (uint256) {
        return _subscriptionManager.getSubscriptionEndTime(tokenId);
    }

    /**
     * @dev Get the subscription duration for a post.
     * @param tokenId The ID of the post (NFT).
     * @return The duration of the subscription in seconds.
     */
    function getSubscriptionDuration(uint256 tokenId) external view returns (uint64) {
        return _subscriptionDurations[tokenId];
    }

    /**
     * @dev Purchase a subscription for a post.
     * @param tokenId The ID of the post (NFT).
     * @param level The subscription level (month, three months, six months, year).
     */
    function purchaseSubscription(uint256 tokenId, uint256 level) external payable {
        require(_exists(tokenId), "Invalid post ID");
        require(msg.value >= _getSubscriptionPrice(tokenId, level), "Insufficient payment");

        uint64 duration = _getSubscriptionDuration(tokenId, level);
        bool renewed = _subscriptionManager.renewSubscription(tokenId, ownerOf(tokenId), duration, block.timestamp);

        if (renewed) {
            _totalSubscriptions[tokenId]++;
            _transferFundsToOwner(msg.value);
        } else {
            revert("Subscription renewal failed"); // Add a reason for revert
        }
    }

    /**
     * @dev Internal function to calculate the subscription price based on the level.
     * @param tokenId The ID of the post (NFT).
     * @param level The subscription level (month, three months, six months, year).
     * @return The calculated subscription price in ETH.
     */
    function _getSubscriptionPrice(uint256 tokenId, uint256 level) internal view returns (uint256) {
        require(level <= 4, "Invalid subscription level");
        uint256 basePrice = _subscriptionPrices[tokenId];
        return basePrice * level;
    }

    /**
     * @dev Internal function to get the subscription duration based on the level.
     * @param tokenId The ID of the post (NFT).
     * @param level The subscription level (month, three months, six months, year).
     * @return The calculated subscription duration in seconds.
     */
    function _getSubscriptionDuration(uint256 tokenId, uint256 level) internal view returns (uint64) {
        require(level <= 4, "Invalid subscription level");
        return uint64(_subscriptionDurations[tokenId] * level);
    }

    /**
     * @dev Internal function to transfer funds to the contract owner.
     * @param amount The amount of funds to transfer.
     */
    function _transferFundsToOwner(uint256 amount) internal {
        uint256 ownerAmount = (amount * OWNER_PERCENTAGE) / 100;
        payable(owner()).transfer(ownerAmount);
    }
}
