// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract  Moderation  {
    address private owner;
    address[] private moderators;
    address[] private blackList;


    modifier onlyOwner(){
        require(msg.sender == owner, "You have no rights");
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

    modifier isNotBanned() {
        bool isBanned = false;
        for (uint256 i = 0; i < blackList.length; i++) {
            if (blackList[i] == msg.sender) {
                isBanned = true;
            }
        }
        require(isBanned == false, "You are banned!");
        _;
    }

    function getModerators() public view returns (address[] memory) {
        return moderators;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function getBanned() public view returns (address[] memory) {
        return blackList;
    }

    function switchToModerator(address user) public onlyOwner {
        moderators.push(user);
    }

    function switchBanned(address user) public onlyModerator isNotBanned {
        blackList.push(user);
    }

    function unBan(address user) public onlyModerator isNotBanned {
        uint256 length = 0;
        for (uint256 i = 0; i < blackList.length; i++) {
            if (blackList[i] != user) {
                length++;
            }
        }
        address[] memory newBlackList = new address[](length);
        uint256 index = 0;
        for (uint256 i = 0; i < blackList.length; i++) {
            if (blackList[i] != user) {
                newBlackList[index] = blackList[i];
                index++;
            }
        }

        blackList = newBlackList;
    }

    constructor() {
        owner = msg.sender;
        moderators.push(msg.sender);
    }
}
