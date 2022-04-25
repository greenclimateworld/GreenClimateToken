const { ethers, upgrades } = require('hardhat');

async function main() {
  try {
    const sWGC = await ethers.getContractFactory('sWGC');
    console.log('Deploying sWGC');

    const stoken = await upgrades.deployProxy(sWGC, [
      "Staked Green Climate Coin",
      "sWGC",
      "0x1941CD62cA8a8269303837B1b900162413FD5bB4", //staking contract
      1000000000, //total supply = wgc token
      9 //decimals
    ], { initializer: 'initialize' });
    await stoken.deployed();
    console.log('sWGC deployed to:', stoken.address);
  } catch (err) {
    console.log(err);
  }
}

main();