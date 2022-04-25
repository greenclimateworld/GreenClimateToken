const { ethers, upgrades } = require('hardhat');

async function main() {
  try {
    const gToken = await ethers.getContractFactory('gWGC');
    console.log('Deploying gToken');
    const gtoken = await gToken.deploy(   
      "Gevernance Green Climate Coin", //name
      "gWGC", //symbol 
     "0xDb38136038C7404e314C82a77AaBB99e2F1303Bd" //sWGC address
     );    
    await gtoken.deployed();
    console.log('gToken deployed to:', gtoken.address);
  } catch (err) {
    console.log(err);
  }
}

main();