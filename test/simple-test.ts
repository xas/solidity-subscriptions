import { expect } from "chai";
import { ethers } from "hardhat";

describe("Simple Subscription", function () {
  it("Should manage subscriptions successfully", async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();
    const Subscription = await ethers.getContractFactory("SubscriptionSimple");
    const subscription = await Subscription.deploy();
    await subscription.deployed();

    expect(await subscription.isSubscriptionValid(addr1.address)).to.equal(false);
    expect(await subscription.isSubscriptionValid(addr2.address)).to.equal(false);

    // Create a subscription for 5 days
    await subscription.mint(addr1.address, 5);

    expect(await subscription.isSubscriptionValid(addr1.address)).to.equal(true);
    expect(await subscription.isSubscriptionValid(addr2.address)).to.equal(false);

    // 6 days later...
    await ethers.provider.send("evm_increaseTime", [86400 * 6]);
    await ethers.provider.send("evm_mine", []);

    expect(await subscription.isSubscriptionValid(addr1.address)).to.equal(false);
    expect(await subscription.isSubscriptionValid(addr2.address)).to.equal(false);
  });
});
