const { ethers, upgrades } = require('hardhat');

async function main() {
  try {
    
    //deploy timelock
    const Staking = await ethers.getContractFactory('WGCStaking');
    console.log('Deploying Staking Contract...');
    const staking = await upgrades.deployProxy(Staking, [], { initializer: 'initialize' });
    await staking.deployed();
    console.log('Staking Contract deployed to:', staking.address);

  } catch (err) {
    console.log(err);
  }
}

main();