//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./ISubscriptionNFT.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SubscriptionErc721 is ISubscriptionNFT, ERC721, Ownable {
    mapping (address => uint256) private _subscriptions;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) Ownable() {
    }

    function mint(address to, uint256 subscriptionId, uint32 period) override external onlyOwner returns (bool) {
        require(to != address(0), "Fake address");
        require(period > 0, "Period cannot be zero");
        require(!_exists(subscriptionId), "Subscription id already used");
        uint endTime = block.timestamp + period * 1 days;
        require(_subscriptions[to] < endTime, "You cannot set a smaller subscription time");
        _subscriptions[to] = endTime;
        _safeMint(to, subscriptionId);
        emit MintedSubscription(to, subscriptionId, endTime);
        return true;
    }

    function isSubscriptionValid(address to, uint256 subscriptionId) override external view returns (bool) {
        require(_exists(subscriptionId), "Subscription id not found");
        require(ownerOf(subscriptionId) == to, "Not owner of this subscription id");
        return _subscriptions[to] > block.timestamp;
    }

    /**
     * @dev Transfers `subscriptionId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `subscriptionId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 subscriptionId
    ) public override {
        require(to != address(0), "ERC721: transfer to the zero address");
        require(_subscriptions[from] > block.timestamp, "You cannot transfer an expired subscription");
        uint endTime = _subscriptions[from];
        require(balanceOf(to) == 0 || _subscriptions[to] < endTime, "Recipient has a better subscription");

        _subscriptions[to] = endTime;
        super.transferFrom(from, to, subscriptionId);
    }
}
