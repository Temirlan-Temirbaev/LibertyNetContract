// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract SocialDonationContract {
    using SafeMath for uint256;

    struct Donation {
        address sender;
        uint256 amount;
    }

    mapping(address => Donation[]) public donations;

    event DonationReceived(address indexed receiver, address indexed sender, uint256 amount);

    modifier nonZeroValue() {
        require(msg.value > 0, "Donation amount must be greater than 0");
        _;
    }

    function makeDonation(address _receiver) external payable nonZeroValue {
        require(_receiver != address(0), "Invalid receiver address");

        donations[_receiver].push(Donation(msg.sender, msg.value));
        emit DonationReceived(_receiver, msg.sender, msg.value);

        payable(_receiver).transfer(msg.value);
    }

    function getDonations(address receiver) external view returns (address[] memory, uint256[] memory) {
        require(receiver != address(0), "Invalid receiver address");

        uint256 length = donations[receiver].length;

        address[] memory senders = new address[](length);
        uint256[] memory amounts = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            senders[i] = donations[receiver][i].sender;
            amounts[i] = donations[receiver][i].amount;
        }

        return (senders, amounts);
    }
}
