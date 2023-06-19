const { ethers, upgrades } = require("hardhat");
const addresses = require("../blockchain/addresses/addresses.json");

async function main() {
  /*const SubscriptionFactory = await ethers.getContractFactory("Subscription");
  const subscription = await upgrades.deployProxy(SubscriptionFactory);*/
  const chainIdHex = await network.provider.send("eth_chainId");
  const chainId = parseInt(chainIdHex, 16);
  const SubscriptionFactory = await ethers.getContractFactory("Subscription");
  console.log(addresses);

  const subscription = await upgrades.upgradeProxy(
    addresses[chainId].Subscription,
    SubscriptionFactory
  );

  const TokenFactory = await ethers.getContractFactory("Token");
  const token = await upgrades.upgradeProxy(
    addresses[chainId].Token,
    TokenFactory
  );
  console.log("Subscription and Token upgraded");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
