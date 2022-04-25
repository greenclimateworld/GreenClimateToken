// scripts/upgrade_Token.js
const { ethers, upgrades } = require('hardhat');

async function main () {
  const Staking = await ethers.getContractFactory('WGCStaking');
  console.log('Upgrading Staking contract...');
  await upgrades.upgradeProxy('0x2D947df38347aAA808a1eECD5e5eCcb4FE359af7', Staking);
  console.log('Staking contract upgraded');
}

main();