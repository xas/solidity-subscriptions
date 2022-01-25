# Subscriptions Models

This is an attempt to define various smart contracts which implement a very basic subscription model.

The main properties are :

* `mint` which will create/update a subscription to an address. You can extend the period, but not decrease it.
* `isSubscriptionValid` a view which indicate if the provided address has a valid subscription (still in the allowed period)
* `MintedSubscription` event to indicate an address get a new _valid_ subscription

No implementation of any kind of `revoke` functions, on purpose.

## SubscriptionSimple

A very basic smart contract using nothing more than the mapping address and the two main functions.  
You mint a subscription linked to an address with a ending time and you can check if the subscription is still valid.  
No transfer available, it's a simple contract.

## SubscriptionErc20

An ERC20 compliant smart contract to manage a unique subscription type. The solution choose here is the subscription is linked with a unique token, and a ending time linked to the address.  
The `balanceOf()` should return 0 or 1 to indicate you have a subscription (expired or not).  
The `transfer()` function allow to transfer a subscription to another address (cool for giveaways).  
Any address should only have one token and so only one subscription.

## SubscriptionErc721

An ERC721 compliant smart contract. This allows a more evolved subscription model.  
The `tokenId` defined in the EIP721 is here a subscription id.  
The `balanceOf()` should return 0 or more, as you can have different subscription id (expired or not).  
The `transferFrom()` function allow to transfer a subscription to another address (cool for giveaways).  
Any address could have as many subscription as available.
