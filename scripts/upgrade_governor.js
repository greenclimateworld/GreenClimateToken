// scripts/upgrade_Token.js
const { ethers, upgrades } = require('hardhat');

async function main () {
  const TimelockController = await ethers.getContractFactory('TimelockController');
  console.log('Upgrading TimelockController...');
  await upgrades.upgradeProxy('address', TimelockController);
  console.log('TimelockController upgraded');

  const Governor = await ethers.getContractFactory('Governor');
  console.log('Upgrading Governor...');
  await upgrades.upgradeProxy('address', Governor);
  console.log('Governor upgraded');
}

main();