require("@nomiclabs/hardhat-waffle");
require('@nomiclabs/hardhat-ethers');
require('@openzeppelin/hardhat-upgrades');
require("@nomiclabs/hardhat-etherscan");
// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
const settings = {
  optimizer: {
    enabled: true,
    runs: 200,
  } 
};

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {  
  networks: {
    bsc: {
      url: "https://bsc-dataseed1.binance.org",
      accounts: [""],
      gas: 8000000
    },    
    ropsten: {
      url: "https://eth-ropsten.alchemyapi.io/v2/zT6MSYFVB-ojEc0-BbokQELJKOl0YxdS",
      accounts: [""],
      gas: 8000000,
      gasPrice: 100000000000,
      timeout: 5000000
    }, 
    bsc_testnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      accounts: [""],
      gas: 8000000
    },
    rinkeby: {
      url: "https://eth-rinkeby.alchemyapi.io/v2/UdVl55H5KSJkdnZfXcn47IC_j3EhObCO",
      accounts: [""],
      gas: 8000000,
      gasPrice: 100000000000,
      timeout: 5000000
    }, 
  },
  solidity: {
    compilers: [
      // { version: '0.5.16', settings },
      // { version: '0.6.12', settings },
      // { version: '0.7.6', settings },
      { version: '0.8.2', settings },
      {
        version: '0.8.11', settings
      },
      {
        version: '0.8.13', settings
      }
    ],

  },
  etherscan: {
    apiKey: "",
  }
};
