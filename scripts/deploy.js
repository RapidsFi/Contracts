// scripts/deploy.ts

const { ethers, network, upgrades } = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  const chainIdHex = await network.provider.send("eth_chainId");
  const chainId = parseInt(chainIdHex, 16);
  const abiDir = path.join(__dirname, "../blockchain/abi");
  const addressDir = path.join(__dirname, "../blockchain/addresses");
  // We get the contract to deploy
  const TokenFactory = await ethers.getContractFactory("Token");
  const token = await upgrades.deployProxy(TokenFactory);
  await token.deployed();
  console.log("Token deployed to:", token.address);

  const SubscriptionFactory = await ethers.getContractFactory("Subscription");
  const subscription = await upgrades.deployProxy(SubscriptionFactory);
  await subscription.deployed();
  console.log("Subscription deployed to:", subscription.address);

  // Copy ABIs to frontend
  if (!fs.existsSync(abiDir)) {
    fs.mkdirSync(abiDir, { recursive: true });
  }

  for (const contractName of ["Token", "Subscription"]) {
    fs.copyFileSync(
      path.join(
        __dirname,
        `../artifacts/contracts/${contractName}.sol/${contractName}.json`
      ),
      path.join(abiDir, `${contractName}.json`)
    );
    console.log(`${contractName} ABI copied to frontend`);
  }

  // Write addresses to JSON file
  const addressesPath = path.join(addressDir, "addresses.json");
  let addresses = {};

  // If addresses file already exists, load it
  if (fs.existsSync(addressesPath)) {
    addresses = JSON.parse(fs.readFileSync(addressesPath, "utf8"));
  }

  // Update addresses for this chain ID
  addresses[chainId] = {
    Token: token.address,
    Subscription: subscription.address,
  };

  // Ensure directory exists
  if (!fs.existsSync(addressDir)) {
    fs.mkdirSync(addressDir, { recursive: true });
  }

  // Write updated addresses back to file
  fs.writeFileSync(addressesPath, JSON.stringify(addresses, null, 2));
  console.log("Addresses written to file:", addresses);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
