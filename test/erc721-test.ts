import { expect, use } from "chai";
import { ethers } from "hardhat";
import { solidity } from "ethereum-waffle";

use(solidity);

describe("ERC721 Subscription", function () {
  it("Should manage subscriptions successfully", async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();
    const subscriptionIds = ["123456", "987654", "159753"];

    const Subscription = await ethers.getContractFactory("SubscriptionErc721");
    const subscription = await Subscription.deploy("Subscription", "PRDSUB");
    await subscription.deployed();

    await expect(subscription.isSubscriptionValid(addr1.address, subscriptionIds[0])).to.be.revertedWith("Subscription id not found");
    await expect(subscription.isSubscriptionValid(addr2.address, subscriptionIds[1])).to.be.revertedWith("Subscription id not found");

    // Create a subscription for 5 days
    await subscription.mint(addr1.address, subscriptionIds[0], 5);

    expect(await subscription.isSubscriptionValid(addr1.address, subscriptionIds[0])).to.equal(true);
    await expect(subscription.isSubscriptionValid(addr2.address, subscriptionIds[0])).to.be.revertedWith("Not owner of this subscription id");

    await subscription.connect(addr1).transferFrom(addr1.address, addr2.address, subscriptionIds[0]);

    await expect(subscription.isSubscriptionValid(addr1.address, subscriptionIds[0])).to.be.revertedWith("Not owner of this subscription id");
    expect(await subscription.isSubscriptionValid(addr2.address, subscriptionIds[0])).to.equal(true);

    // 6 days later...
    await ethers.provider.send("evm_increaseTime", [86400 * 6]);
    await ethers.provider.send("evm_mine", []);

    expect(await subscription.isSubscriptionValid(addr2.address, subscriptionIds[0])).to.equal(false);
  });
});
