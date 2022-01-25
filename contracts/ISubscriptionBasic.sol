//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface ISubscriptionBasic {

    event MintedSubscription(address indexed to, uint endTime);

    function mint(address to, uint32 period) external returns (bool);
    function isSubscriptionValid(address to) external view returns (bool);
}