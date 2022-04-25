# Basic Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts.

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```

npx hardhat run --network bsc_testnet scripts/deploy_upgradeable_stake.js
0x09887f988cc225aC825f4a38919BF2FccfB36188

npx hardhat run --network bsc_testnet scripts/deploy_upgradeable_treasury.js
exponentation : 0x0d5bf1c01EaECf6871345AF0A8A1D2F2ad6b311D
treasury : 0x25432AC10066bEA5534C32dacd15Db389D06410c


npx hardhat run --network bsc_testnet scripts/deploy_upgradeable_token.js
0x1D8f421cc89bc0F78E14f454ABd22bFef68D28C7
npx hardhat run --network bsc_testnet scripts/deploy_upgradeable_sToken.js
0x647A9a7890ba3dd2B5e4672780b7545473c8E8fE

npx hardhat run --network bsc_testnet scripts/deploy_wrapper.js
0xAdFA42A8B77F2b9Fc45Ed394618b6B2a5Ff0a62d


npx hardhat run --network bsc_testnet scripts/deploy_gToken.js
0x5eeeAE8e169b69c062ebf4BfE5Db3Db4332A2666

npx hardhat run --network bsc_testnet scripts/deploy_upgradeable_governor.js
timelock : 0x28b6137F31C4B26a7ab7a6BAF06B040B19f51Ab9
governor : 0x660c0356F0884C5543F46A7658ffe5Bb8864A6c5

gWGC should be excluded from the reward for sWGC
