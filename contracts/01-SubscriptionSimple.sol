//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ISubscriptionBasic.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SubscriptionSimple is ISubscriptionBasic, Ownable {
    mapping (address => uint256) private _subscriptions;

    constructor() Ownable() { }

    function mint(address to, uint32 period) override external onlyOwner returns (bool) {
        require(to != address(0), "Fake address");
        require(period > 0, "Period cannot be zero");
        uint endTime = block.timestamp + period * 1 days;
        require(_subscriptions[to] < endTime, "You cannot set a smaller subscription time");
        _subscriptions[to] = endTime;
        emit MintedSubscription(to, endTime);
        return true;
    }

    function isSubscriptionValid(address to) override external view returns (bool) {
        require(to != address(0), "Fake address");
        return _subscriptions[to] > block.timestamp;
    }
}
