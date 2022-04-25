// scripts/upgrade_Token.js
const { ethers, upgrades } = require('hardhat');

async function main () {
  const WGC = await ethers.getContractFactory('WGC');
  console.log('Upgrading WGC contract...');
  await upgrades.upgradeProxy('0x1D8292F53363Dc08279dB17D3311F6823541a77B', WGC);
  console.log('WGC contract upgraded');
}

main();