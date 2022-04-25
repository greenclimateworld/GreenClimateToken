const { ethers, upgrades } = require('hardhat');

async function main() {
  try {
    const Exponentation = await ethers.getContractFactory('Exponentation');
    console.log('Deploying Exponentation');
    const exponentation = await Exponentation.deploy();    
    await exponentation.deployed();
    console.log('exponentation deployed to:', exponentation.address);


    //deploy Treasury
    const Treasury = await ethers.getContractFactory('WGCTreasury');
    console.log('Deploying Treasury Contract...');
    const treasury = await upgrades.deployProxy(Treasury, [exponentation.address], { initializer: 'initialize' });
    await treasury.deployed();
    console.log('Treasury Contract deployed to:', treasury.address);

  } catch (err) {
    console.log(err);
  }
}

main();