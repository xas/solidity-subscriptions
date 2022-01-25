import { expect } from "chai";
import { ethers } from "hardhat";

describe("ERC20 Subscription", function () {
  it("Should manage subscriptions successfully", async function () {
    const [owner, addr1, addr2] = await ethers.getSigners();
    const Subscription = await ethers.getContractFactory("SubscriptionErc20");
    const subscription = await Subscription.deploy("Subscription", "PRDSUB");
    await subscription.deployed();

    expect(await subscription.isSubscriptionValid(addr1.address)).to.equal(false);
    expect(await subscription.isSubscriptionValid(addr2.address)).to.equal(false);

    // Create a subscription for 5 days
    await subscription.mint(addr1.address, 5);

    expect(await subscription.isSubscriptionValid(addr1.address)).to.equal(true);
    expect(await subscription.isSubscriptionValid(addr2.address)).to.equal(false);

    await subscription.connect(addr1).transfer(addr2.address, 1);

    expect(await subscription.isSubscriptionValid(addr1.address)).to.equal(false);
    expect(await subscription.isSubscriptionValid(addr2.address)).to.equal(true);

    // 6 days later...
    await ethers.provider.send("evm_increaseTime", [86400 * 6]);
    await ethers.provider.send("evm_mine", []);

    expect(await subscription.isSubscriptionValid(addr1.address)).to.equal(false);
    expect(await subscription.isSubscriptionValid(addr2.address)).to.equal(false);
  });
});
