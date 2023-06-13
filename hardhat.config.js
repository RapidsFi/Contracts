require("@nomicfoundation/hardhat-toolbox");
require("@openzeppelin/hardhat-upgrades");
require("dotenv").config();

const INFURA_API_KEY = process.env.INFURA_API_KEY;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;

module.exports = {
  solidity: {
    version: "0.8.8",
    settings: {
      optimizer: {
        enabled: true,
        runs: 100, // Adjust the number of runs to balance deployment cost vs. transaction cost
      },
    },
  },
  networks: {
    sepolia: {
      url: `https://sepolia.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [
        process.env.SEPOLIA_PRIVATE_KEY,
        process.env.SEPOLIA_PRIVATE_KEY_2,
      ],
      gas: 8000000,
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [
        process.env.SEPOLIA_PRIVATE_KEY,
        process.env.SEPOLIA_PRIVATE_KEY_2,
      ],
    },
  },
  defaultNetwork: "hardhat",
  mocha: {
    timeout: 60000, // 60 seconds
  },
};
