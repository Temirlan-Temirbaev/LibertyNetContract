const {expect} = require("chai");
const {ethers} = require("hardhat")

describe("SocialMediaSubscription", function () {
  let SocialMediaSubscription;
  let socialMediaSubscription;
  let owner;
  let user;
  let tokenId;

  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();
    SocialMediaSubscription = await ethers.getContractFactory("SocialMediaSubscription");
    socialMediaSubscription = await SocialMediaSubscription.deploy("SocialMedia", "SM");
    tokenId = 1;
  });

  it("should set subscription price and duration", async function () {
    const duration = 86400; // 1 day in seconds
    const price = ethers.parseEther("0.01");

    await socialMediaSubscription.setSubscriptionPriceAndDuration(tokenId, duration, price);

    const actualPrice = await socialMediaSubscription.getSubscriptionPrice(tokenId);
    const actualDuration = await socialMediaSubscription.getSubscriptionDuration(tokenId);

    expect(actualPrice).to.equal(price);
    expect(actualDuration).to.equal(duration);
  });

});
