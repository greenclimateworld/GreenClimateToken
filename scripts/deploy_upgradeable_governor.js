const { ethers, upgrades } = require('hardhat');

async function main() {
  try {
    
    //deploy timelock
    const TimelockController = await ethers.getContractFactory('TimelockController');
    console.log('Deploying TimelockController...');
    const timelockController = await upgrades.deployProxy(TimelockController, [
      1000, //minimum delay time 1000s
      [], // proposer  address,  it will be replaced with governor address after the governor deployed
      ["0x0000000000000000000000000000000000000000"] // executor
    ], { initializer: 'initialize' });
    await timelockController.deployed();
    console.log('TimelockController deployed to:', timelockController.address);

    //deploy Governor
    const Governor = await ethers.getContractFactory('Governor');
    console.log('Deploying Governor...');
    const governor = await upgrades.deployProxy(Governor, [
      "Gems Governor", //DAO name
      "0xE6fc72E0bBe7010cC5FAE5a5de6D785b9fB90122", //staked token address
      timelockController.address,
      1000, //voting delay
      86400, //voting period
      4 // quorum fraction 4%
    ], { initializer: 'initialize' });
    await governor.deployed();
    console.log('Governor deployed to:', governor.address);
    const proposer_role=await timelockController.PROPOSER_ROLE();
    const canceller_role=await timelockController.CANCELLER_ROLE();
    await timelockController.grantRole(proposer_role, governor.address);
    await timelockController.grantRole(canceller_role, governor.address);

  } catch (err) {
    console.log(err);
  }
}

main();