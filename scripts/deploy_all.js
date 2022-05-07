const { ethers, upgrades } = require('hardhat');

async function main() {
    try {
        //deploy stake
        const Staking = await ethers.getContractFactory('WGCStaking');
        console.log('Deploying Staking Contract...');
        const staking = await upgrades.deployProxy(Staking, [], { initializer: 'initialize' });
        await staking.deployed();
        console.log('Staking Contract deployed to:', staking.address);

        //deploy Exponentation
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

        //deploy WGC
        const WGC = await ethers.getContractFactory('WGC');
        console.log('Deploying WGC');

        const token = await upgrades.deployProxy(WGC, [
            "0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3", // pancake router address
            treasury.address, // treasury contract address
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

        //deply sWGC
        const sWGC = await ethers.getContractFactory('sWGC');
        console.log('Deploying sWGC');

        const stoken = await upgrades.deployProxy(sWGC, [
            "Staked Green Climate Coin",
            "sWGC",
            staking.address, //staking contract
            1000000000, //total supply = wgc token
            9 //decimals
        ], { initializer: 'initialize' });
        await stoken.deployed();
        console.log('sWGC deployed to:', stoken.address);

        //wrapper for old token
        const WGCWrapper = await ethers.getContractFactory('WGCWrapper');
        console.log('Deploying Wrapper Contract...');


        const wrapper = await WGCWrapper.deploy(
            "0xCCb201febcd680c9fc48748eDc583CbfF7B4e989", //old token address
            token.address //new token address
        );
        await wrapper.deployed();
        console.log('Wrapper Contract deployed to:', wrapper.address);



        //deploy gWGC
        const gToken = await ethers.getContractFactory('gWGC');
        console.log('Deploying gToken');
        const gtoken = await gToken.deploy(
            "Gevernance Green Climate Coin", //name
            "gWGC", //symbol 
            stoken.address //sWGC address
        );
        await gtoken.deployed();
        console.log('gToken deployed to:', gtoken.address);

        //configuration
        await staking.updateConfiguration(
            token.address,
            stoken.address,
            treasury.address,
            100
        );
        console.log('stake contract is configurated with WGC, sWGC, treasury, and minimum amount!');
        await token.excludeFromFee(staking.address);
        await token.excludeFromFee(wrapper.address);
        await token.excludeFromMaxTransaction(staking.address, true);
        await token.excludeFromMaxTransaction(wrapper.address, true);
        console.log('WGC contract is configurated with stake and wrapper address for exclude from fee and max transaction!');
        await stoken.excludeFromReward(gtoken.address);
        console.log('sWGC contract is configurated with gWGC address for exclude from reward!');
        const governor_role=await treasury.GOVERNOR_ROLE();
        const stake_role=await treasury.STAKE_ROLE();
        await treasury.grantRole(governor_role, "0x4984aefC02674b60D40ef57FAA158140AE69c0a8");
        await treasury.grantRole(stake_role, staking.address);
        console.log("Grant role in treasury - staking and governor");
        await treasury.setTokenAddress(token.address);
        console.log("Treasury configuration - WGC address");
        await treasury.setStakingRewardPercent(
            18880000, //block number
            5
        );
        console.log("Treasury configuration - staking reward");

        //deploy governor
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
            "WGC Governor", //DAO name
            gtoken.address, //gToken address
            timelockController.address,
            1000, //voting delay
            86400, //voting period
            4 // quorum fraction 4%
        ], { initializer: 'initialize' });
        await governor.deployed();
        console.log('Governor deployed to:', governor.address);
        const proposer_role = await timelockController.PROPOSER_ROLE();
        const canceller_role = await timelockController.CANCELLER_ROLE();
        await timelockController.grantRole(proposer_role, governor.address);
        await timelockController.grantRole(canceller_role, governor.address);


        /////  transfer ownership to governance
        // await staking.transferOwnership(governor.address);
        // await token.transferOwnership(governor.address);
        // await stoken.transferOwnership(governor.address);
        // await wrapper.transferOwnership(governor.address);
        // await treasury.grantRole(governor_role, governor.address);
        // console.log("DAO completed");
    } catch (err) {
        console.log(err);
    }
}

main();