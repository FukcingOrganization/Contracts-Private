require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");

// Infomation
let mmKey = "0x" + "edb4b5f402a5dcdd9c81f1d61f4e0aa6842c22158905ad4a74a9b37f6e874073";
let infura_arbiGoerli = "https://arbitrum-goerli.infura.io/v3/1a1dd7e492854a259e3d84f724f624f0";
let arbiScanApiKey = "2QDZH7J3JYKCW2Q2M42G1MXU5Z95EYUU2U";

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity:{
    compilers: [{ version: "0.8.17", settings: {
      optimizer: {
        runs: 200,
        enabled: true
      }
    } }, { version: "0.6.12"}],
  },
  mocha: {
    timeout: 300000, // 300 seconds max
  },
  networks: {
    arbitrumGoerli: {
      url: infura_arbiGoerli,
      accounts: [mmKey],      
    }
  },
  etherscan: {
    apiKey: {
        mainnet: "YOUR_ETHERSCAN_API_KEY",
        optimisticEthereum: "YOUR_OPTIMISTIC_ETHERSCAN_API_KEY",
        arbitrumGoerli: arbiScanApiKey,
    }
  }
};
