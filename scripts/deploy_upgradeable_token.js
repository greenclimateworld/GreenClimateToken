const { ethers, upgrades } = require('hardhat');

async function main() {
  try {
    const WGC = await ethers.getContractFactory('WGC');
    console.log('Deploying WGC'); 

    const token = await upgrades.deployProxy(WGC, [
      "0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3", // pancake router address
      "0x2D947df38347aAA808a1eECD5e5eCcb4FE359af7", // staking contract address
      "0x4984aefC02674b60D40ef57FAA158140AE69c0a8", // liquidity address
      "0x4984aefC02674b60D40ef57FAA158140AE69c0a8", // planting fund fee wallet address      
      [
        3, //protect block count for anti sniper
        5, // gas price limit = 50Gwei
        60, // liquidity fee in protect blocks = 6%
        50, // reward fee for stakers in protect blocks = 5%
        30, //planting fund fee in protect block =3%
        60, // buy liquidity fee  = 6%
        50, // buy reward fee for stakers  = 5%
        30, // buy planting fund fee  =3%
        60, // sell liquidity fee  = 6%
        50, // sell reward fee for stakers  = 5%
        30, // sell planting fund fee  =3%
        10000, // minimum amount of token for fee to take
        1000, // max transaction limit
        10000000, // max amount for a wallet    
        0, // transfer liquidity fee  = 6%
        0, // transfer reward fee for stakers  = 5%
        0, // transfer planting fund fee  =3%  
        1000000000 //total supply
      ],
      "Green Climate Coin", //name
      "WGC", //symbol
      9 // decimals
    ], { initializer: 'initialize' });
    await token.deployed();
    console.log('WGC deployed to:', token.address);
  } catch (err) {
    console.log(err);
  }
}

main();