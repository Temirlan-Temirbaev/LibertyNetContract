const { expect } = require("chai");

describe("Moderation", function () {
  let Moderation;
  let moderation;
  let owner;
  let moderator1;
  let moderator2;
  let user1;
  let user2;

  beforeEach(async function () {
    [owner, moderator1, moderator2, user1, user2] = await ethers.getSigners();
    Moderation = await ethers.getContractFactory("Moderation");
    moderation = await Moderation.deploy();
  });

  it("should set the deployer as the owner and a moderator", async function () {
    const ownerAddress = await moderation.getOwner();
    const moderators = await moderation.getModerators();

    expect(ownerAddress).to.equal(await owner.getAddress());
    expect(moderators).to.deep.equal([await owner.getAddress()]);
  });

  it("should switch user to a moderator", async function () {
    await moderation.connect(owner).switchToModerator(await moderator1.getAddress());

    const moderators = await moderation.getModerators();
    expect(moderators).to.deep.equal([await owner.getAddress(), await moderator1.getAddress()]);
  });

  it("should allow a moderator to switch a user to the banned list", async function () {
    await moderation.connect(owner).switchToModerator(await moderator1.getAddress());
    await moderation.connect(moderator1).switchBanned(await user1.getAddress());

    const bannedList = await moderation.getBanned();
    expect(bannedList).to.deep.equal([await user1.getAddress()]);
  });

  it("should allow a moderator to unban a user", async function () {
    await moderation.connect(owner).switchToModerator(await moderator1.getAddress());
    await moderation.connect(moderator1).switchBanned(await user1.getAddress());
    await moderation.connect(moderator1).unBan(await user1.getAddress());

    const bannedList = await moderation.getBanned();
    expect(bannedList).to.deep.equal([]);
  });

  it("should prevent non-moderators from switching a user to the banned list", async function () {
    await expect(moderation.connect(user1).switchBanned(await user2.getAddress())).to.be.revertedWith(
      "You have no rights to this function"
    );
  });

  it("should prevent banned users from invoking functions with 'isNotBanned' modifier", async function () {
    await moderation.connect(owner).switchToModerator(await moderator1.getAddress());
    await moderation.connect(moderator1).switchBanned(await user1.getAddress());

    await expect(moderation.connect(user1).switchToModerator(await moderator2.getAddress())).to.be.revertedWith(
      "You have no rights"
    );
  });
});
