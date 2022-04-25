// scripts/upgrade_Token.js
const { ethers, upgrades } = require('hardhat');

async function main () {
  const Treasury = await ethers.getContractFactory('WGCTreasury');
  console.log('Upgrading Treasury contract...');
  await upgrades.upgradeProxy('0xc28035b9cf8f355484B67bD76b310f1B2afAEC07', Treasury);
  console.log('Treasury contract upgraded');
}

main();