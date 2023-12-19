const { expect } = require("chai");

describe("UserNFT", function () {
  let UserNFT;
  let userNFT;

  beforeEach(async function () {
    UserNFT = await ethers.getContractFactory("UserNFT");
    userNFT = await UserNFT.deploy();
  });

  it("should mint NFT with user data", async function () {
    const nickname = "Alice";
    const avatar = "https://example.com/avatar.png";

    const [signer] = await ethers.getSigners();

    await userNFT.connect(signer).mintUserNFT(nickname, avatar);

    const tokenId = 0;

    const user = await userNFT.userData(tokenId);
    expect(user.userAddress).to.equal(await signer.getAddress());
    expect(user.nickname).to.equal(nickname);
    expect(user.avatar).to.equal(avatar);

    const owner = await userNFT.ownerOf(tokenId);
    expect(owner).to.equal(await signer.getAddress());
  });

  it("should increment nextTokenId after minting", async function () {
    const initialNextTokenId = await userNFT.nextTokenId();

    const nickname = "Bob";
    const avatar = "https://example.com/bob-avatar.png";
    await userNFT.mintUserNFT(nickname, avatar);

    const newNextTokenId = await userNFT.nextTokenId();
    expect(Number(newNextTokenId)).to.equal(Number(initialNextTokenId) + 1);
  });
});
