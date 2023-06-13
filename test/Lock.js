const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Subscription", function () {
  let Subscription, subscription, Token, token, owner;
  let tokenAddress; // DAI address

  beforeEach(async function () {
    Subscription = await ethers.getContractFactory("Subscription");
    Token = await ethers.getContractFactory("Token");
    token = await Token.deploy();

    [owner] = await ethers.getSigners();

    // Assuming DAI is deployed on the network, replace with actual DAI address.
    console.log("Token address: ", token.address);

    subscription = await Subscription.deploy();
    await subscription.deployed();
  });

  it("Should set the correct author and toAddress", async function () {
    expect(await subscription.author()).to.equal(owner.address);
  });
});
