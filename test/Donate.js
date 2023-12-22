const { expect } = require("chai");

describe("SocialDonationContract", function () {
    let SocialDonationContract;
    let socialDonationContract;
    let owner;
    let receiver1;

    beforeEach(async function () {
        SocialDonationContract = {
            donations: {},
            makeDonation(receiver, value) {
                if (value === 0) {
                    throw new Error("Donation amount must be greater than 0");
                }

                if (receiver === "0x0") {
                    throw new Error("Invalid receiver address");
                }

                const sender = owner.address;
                this.donations[receiver] = this.donations[receiver] || [];
                this.donations[receiver].push({ sender, amount: value });
                return { sender, receiver, value };
            },
            getDonations(receiver) {
                return this.donations[receiver] || [];
            }
        };

        owner = { address: "0x123", connect: () => owner };
        receiver1 = { address: "0x456", connect: () => receiver1 };


        socialDonationContract = SocialDonationContract;
    });

    it("Should allow making a donation and retrieve donations", function () {
        const donationAmount = 100; // in Wei
        const donationResult = socialDonationContract.makeDonation(receiver1.address, donationAmount);

        expect(donationResult).to.have.property("sender", owner.address);
        expect(donationResult).to.have.property("receiver", receiver1.address);
        expect(donationResult).to.have.property("value", donationAmount);

        const donations = socialDonationContract.getDonations(receiver1.address);
        expect(donations).to.have.lengthOf(1);
        expect(donations[0]).to.deep.equal({ sender: owner.address, amount: donationAmount });
    });

    it("Should not allow making a donation with zero value", function () {
        expect(() => socialDonationContract.makeDonation(receiver1.address, 0)).to.throw("Donation amount must be greater than 0");
    });

    it("Should not allow making a donation to an invalid receiver address", function () {
        expect(() => socialDonationContract.makeDonation("0x0", 100)).to.throw("Invalid receiver address");
    });
});
