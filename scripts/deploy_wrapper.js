const { ethers, upgrades } = require('hardhat');

async function main() {
  try {    
    const WGCWrapper = await ethers.getContractFactory('WGCWrapper');
    console.log('Deploying Wrapper Contract...');

 
    const wrapper = await WGCWrapper.deploy(
      "0xCCb201febcd680c9fc48748eDc583CbfF7B4e989", //old token address
      "0x1D8292F53363Dc08279dB17D3311F6823541a77B" //new token address
      );
    await wrapper.deployed();
    console.log('Wrapper Contract deployed to:', wrapper.address);

  } catch (err) {
    console.log(err);
  }
}

main();