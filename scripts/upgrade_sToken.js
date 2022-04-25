// scripts/upgrade_Token.js
const { ethers, upgrades } = require('hardhat');

async function main () {
  const sWGC = await ethers.getContractFactory('sWGC');
  console.log('Upgrading WGC contract...');
  await upgrades.upgradeProxy('0x1C033Ef7cA16DE3a4c4E1D53121fCDEA19D4CfBb', sWGC);
  console.log('sWGC contract upgraded');
}

main();