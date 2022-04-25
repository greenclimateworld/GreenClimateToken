// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./Exponentation.sol";

contract WGCTreasury is Initializable, AccessControlUpgradeable {
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeERC20Upgradeable for ERC20Upgradeable;

    uint256 public constant TWO_127 = 170141183460469231731687303715884105728;
    Exponentation public exponentation;
    IERC20Upgradeable public wgc;

    mapping(uint256 => uint256) public rewardHistory;
    uint256[] public rewardBlocks;

    uint256 public stakingRewardLastBlock;
    uint256 public stakingRewardAmountDistributed;
    mapping(uint256 => uint256) public stakingRewardPercentPerBlock;
    uint256[] public stakingRewardBlocksSet;

    bytes32 public constant GOVERNOR_ROLE = keccak256("GOVERNOR_ROLE");
    bytes32 public constant STAKE_ROLE = keccak256("STAKE_ROLE");

    event TransactionRewardFeeTaken(uint256 blockNumber, uint256 rewardHistory);
    event SetToken(address token);
    event SetStakingRewardPercent(
        uint256 blockNumber,
        uint256 stakingRewardPercentPerBlock
    );
    event DistributeStakingReward(uint256 blockNumber, uint256 rewardAmount);

    function initialize(address _addr) public initializer {
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        exponentation = Exponentation(_addr);
    }

    function depositReward(uint256 amount) external {
        uint256 balanceBefore = wgc.balanceOf(address(this));
        wgc.safeTransferFrom(msg.sender, address(this), amount);
        uint256 _tBalanceAdded = wgc.balanceOf(address(this)).sub(
            balanceBefore
        );
        if (_tBalanceAdded > 0) {
            rewardBlocks.push(block.number);
            rewardHistory[block.number] = _tBalanceAdded;
            emit TransactionRewardFeeTaken(
                block.number,
                rewardHistory[block.number]
            );
        }
    }

    function setTokenAddress(address _token) public onlyRole(GOVERNOR_ROLE) {
        require(_token != address(0), "can't set address 0");
        wgc = IERC20Upgradeable(_token);
        emit SetToken(_token);
    }

  

    function setExponentContractAddress(address _addr)
        public
        onlyRole(GOVERNOR_ROLE)
    {
        require(_addr != address(0), "can't set address 0");
        exponentation = Exponentation(_addr);
    }

    function setStakingRewardPercent(
        uint256 _blockNumber,
        uint256 _stakingRewardPercentPerBlock
    ) public onlyRole(GOVERNOR_ROLE) {
        require(_blockNumber >= block.number, "no allowed for passed blocks");
        require(
            _stakingRewardPercentPerBlock <= 1000000,
            "staking reward percentage < 1%"
        );
        stakingRewardBlocksSet.push(_blockNumber);
        stakingRewardPercentPerBlock[
            _blockNumber
        ] = _stakingRewardPercentPerBlock;
        emit SetStakingRewardPercent(
            _blockNumber,
            _stakingRewardPercentPerBlock
        );
    }

    function distributeStakingReward() external onlyRole(STAKE_ROLE) {
        if (block.number == stakingRewardLastBlock) return;
        uint256 balanceOfStake = wgc.balanceOf(msg.sender);
        uint256 rewardAmount = balanceOfStake;
        uint256 blockCount;
        uint256 times;
        for (uint256 i = stakingRewardBlocksSet.length; i > 0; --i) {
            if (stakingRewardBlocksSet[i-1] < stakingRewardLastBlock) {
                if (i == stakingRewardBlocksSet.length) {
                    blockCount = block.number - stakingRewardLastBlock;
                } else {
                    blockCount =
                        stakingRewardBlocksSet[i] -
                        stakingRewardLastBlock;
                }
                if (
                    stakingRewardPercentPerBlock[stakingRewardBlocksSet[i-1]] == 0
                ) break;
                times = exponentation
                    .power(
                        (100000000+stakingRewardPercentPerBlock[stakingRewardBlocksSet[i-1]]),
                        100000000,
                        blockCount,
                        1
                    )
                    .mul(10000000000)
                    .div(TWO_127);
                rewardAmount = rewardAmount.mul(times).div(
                    10000000000
                );
                break;
            }
            if(stakingRewardBlocksSet[i-1]>=block.number)
                continue;
            if (i == stakingRewardBlocksSet.length) {
                blockCount = block.number - stakingRewardBlocksSet[i-1];
            } else {
                blockCount =
                    stakingRewardBlocksSet[i] -
                    stakingRewardBlocksSet[i-1];
            }
            if (stakingRewardPercentPerBlock[stakingRewardBlocksSet[i-1]] == 0)
                continue;
            times = exponentation
                .power(
                    (100000000+stakingRewardPercentPerBlock[stakingRewardBlocksSet[i-1]]),
                    100000000,
                    blockCount,
                    1
                )
                .mul(10000000000)
                .div(TWO_127);
            rewardAmount = rewardAmount.mul(times).div(
                10000000000
            );
        }
        rewardAmount = rewardAmount.sub(balanceOfStake);
        stakingRewardLastBlock = block.number;
        rewardAmount = rewardAmount > wgc.balanceOf(address(this))
            ? wgc.balanceOf(address(this))
            : rewardAmount;
        if (rewardAmount > 0) {
            wgc.safeTransfer(msg.sender, rewardAmount);
        }
        stakingRewardAmountDistributed = stakingRewardAmountDistributed.add(
            rewardAmount
        );
        emit DistributeStakingReward(block.number, rewardAmount);
    }


    function stakingRewardBlocksSetLength() external view returns (uint256){
        return stakingRewardBlocksSet.length;
    }
}
