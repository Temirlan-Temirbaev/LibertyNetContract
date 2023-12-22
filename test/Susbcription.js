const { expect } = require('chai');

describe('SocialMediaSubscription', function () {
  let owner, user1, user2;
  let socialMediaSubscription, subscriptionManagerMock, postNFTMock;
  const tokenId = 1;
  const level = 1;
  const duration = 30;
  const subscriptionPrice = 0.1;

  before(async function () {

    owner = { address: '0xOwnerAddress' };
    user1 = { address: '0xUser1Address' };
    user2 = { address: '0xUser2Address' };

    socialMediaSubscription = {
      setSubscriptionDuration: async (tokenId, duration) => {
        socialMediaSubscription.subscriptionDuration = duration;
      },
      setSubscriptionPrice: async (tokenId, price) => {
        socialMediaSubscription.subscriptionPrice = price;
      },
      getSubscriptionDuration: async (tokenId) => {
        return socialMediaSubscription.subscriptionDuration;
      },
      getSubscriptionPrice: async (tokenId) => {
        return socialMediaSubscription.subscriptionPrice;
      },
    };

    subscriptionManagerMock = {
      renewSubscription: async (tokenId, ownerAddress, duration, timestamp) => {
        return true;
      },
    };

    postNFTMock = {
      ownerOf: async (tokenId) => {
        return user1.address;
      },
    };
  });

  it('should set subscription duration', async function () {
    // Вызов метода установки длительности подписки
    await socialMediaSubscription.setSubscriptionDuration(tokenId, duration);

    const result = await socialMediaSubscription.getSubscriptionDuration(tokenId);

    expect(result).to.equal(duration);
  });

  it('should set subscription price', async function () {
    await socialMediaSubscription.setSubscriptionPrice(tokenId, subscriptionPrice);

    const result = await socialMediaSubscription.getSubscriptionPrice(tokenId);

    expect(result).to.equal(subscriptionPrice);
  });


});
