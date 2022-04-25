const { ethers, upgrades } = require('hardhat');

async function main () {
  try{
    const BridgeBase = await ethers.getContractFactory('BridgeBase');
    console.log('Deploying BridgeBase...');
    const bridgeBase = await upgrades.deployProxy(BridgeBase, 
      ["0x5A297809fd9Bac9a820acB00fE538aAA6498FA3C", "0x1D8f421cc89bc0F78E14f454ABd22bFef68D28C7"], 
    { initializer: 'initialize' });
    await bridgeBase.deployed();
    console.log('BridgeBase deployed to:', bridgeBase.address);
  }catch(err){
    console.log(err);
  }
}

main();