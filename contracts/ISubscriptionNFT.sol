//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface ISubscriptionNFT {

    event MintedSubscription(address indexed to, uint256 indexed subscriptionId, uint endTime);

    function mint(address to, uint256 subscriptionId, uint32 period) external returns (bool);
    function isSubscriptionValid(address to, uint256 subscriptionId) external view returns (bool);
}