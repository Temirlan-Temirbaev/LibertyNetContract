const {expect} = require("chai");

describe("PostNFT", function () {
  let PostNFT;
  let postNFT;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    PostNFT = await ethers.getContractFactory("PostNFT");
    postNFT = await PostNFT.deploy();
  });

  it("should mint Post NFT", async function () {
    const content = "Hello, world!";
    const mediaContentUrl = "https://example.com/image.jpg";
    const id = 1;

    await postNFT.connect(addr1).mintPostNFT(content, mediaContentUrl, id);

    const tokenId = 0; // Assuming the first token is minted

    const post = await postNFT.postData(tokenId);
    expect(post.content).to.equal(content);
    expect(post.mediaContentUrl).to.equal(mediaContentUrl);
    expect(post.author).to.equal(await addr1.getAddress());
    expect(post.postId).to.equal(id);

    const ownerOfToken = await postNFT.ownerOf(tokenId);
    expect(ownerOfToken).to.equal(await addr1.getAddress());
  });

  it("should allow editing by the owner", async function () {
    const content = "Hello, world!";
    const mediaContentUrl = "https://example.com/image.jpg";
    const id = 1;

    await postNFT.connect(addr1).mintPostNFT(content, mediaContentUrl, id);

    const tokenId = 0; // Assuming the first token is minted

    const newContent = "Updated content";
    const newMediaContentUrl = "https://example.com/updated-image.jpg";

    await postNFT.connect(addr1).edit(newContent, newMediaContentUrl, tokenId);

    const updatedPost = await postNFT.postData(tokenId);
    expect(updatedPost.content).to.equal(newContent);
    expect(updatedPost.mediaContentUrl).to.equal(newMediaContentUrl);
  });

  it("should not allow editing by non-owners", async function () {
    const content = "Hello, world!";
    const mediaContentUrl = "https://example.com/image.jpg";
    const id = 1;

    await postNFT.connect(addr1).mintPostNFT(content, mediaContentUrl, id);

    const tokenId = 0; // Assuming the first token is minted

    const newContent = "Updated content";
    const newMediaContentUrl = "https://example.com/updated-image.jpg";

    await expect(postNFT.connect(addr2).edit(newContent, newMediaContentUrl, tokenId)).to.be.revertedWith(
      "You don't have permission to edit this post"
    );
  });
});
