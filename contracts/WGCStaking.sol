// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";

interface ISToken is IERC20Upgradeable{   
    function distributeRewards(uint256 amount) external returns (bool succeed);
}

interface ITreasury{   
    function distributeStakingReward() external;
}

contract WGCStaking is Initializable, OwnableUpgradeable {
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SafeERC20Upgradeable for ERC20Upgradeable;
    using SafeERC20Upgradeable for ISToken;
    ERC20Upgradeable public wgc;
    ISToken public sWgc;
    ITreasury public treasury;

    uint256 public minimumLimitToStake;
    mapping(uint256=>uint256) public rewardHistory;
    uint256[] public rewardBlocks;
    uint256 public totalStaked;

    event Rebase(uint256 block, uint256 rewardHistory);
    event Stake(address sender, uint256 amount);
    event Unstake(address sender, uint256 amount);

    function updateConfiguration(address _wgc, address _sWgc, address _treasury, uint256 _minimumLimitToStake) public onlyOwner {
        wgc = ERC20Upgradeable(_wgc);
        sWgc = ISToken(_sWgc);
        treasury = ITreasury(_treasury);
        minimumLimitToStake=_minimumLimitToStake*10**wgc.decimals();

    }
    function initialize() public initializer {
        __Ownable_init();        
    }

    function stake(uint256 amount) public {
        uint256 originSTokenAmount = sWgc.balanceOf(msg.sender);
        uint256 balanceBefore = wgc.balanceOf(address(this));
        wgc.safeTransferFrom(msg.sender, address(this), amount);
        uint256 _tBalanceAdded = wgc.balanceOf(address(this)).sub(
            balanceBefore
        );
        require(_tBalanceAdded.add(originSTokenAmount)>=minimumLimitToStake, "less than limit");
        sWgc.safeTransfer(msg.sender,_tBalanceAdded);
        totalStaked=totalStaked.add(_tBalanceAdded);
        emit Stake(msg.sender, _tBalanceAdded);
    }

    function unstake(uint256 amount) public {
        rebase();

        uint256 balanceBefore = sWgc.balanceOf(address(this));
        sWgc.safeTransferFrom(msg.sender, address(this), amount);
        uint256 _tBalanceAdded = sWgc.balanceOf(address(this)).sub(
            balanceBefore
        );
        wgc.safeTransfer(msg.sender,_tBalanceAdded);
        totalStaked=totalStaked.sub(_tBalanceAdded);
        emit Unstake(msg.sender, _tBalanceAdded);
    }

    function rebase() public returns (uint256) {
        uint256 balanceBefore = wgc.balanceOf(address(this));
        treasury.distributeStakingReward();
        uint256 _tBalanceAdded = wgc.balanceOf(address(this)).sub(
            balanceBefore
        );
        if(_tBalanceAdded>0){
            bool succeed=sWgc.distributeRewards(_tBalanceAdded);
            if(succeed){
                totalStaked=totalStaked.add(_tBalanceAdded);
                rewardBlocks.push(block.number);
                rewardHistory[block.number]=_tBalanceAdded;
                emit Rebase(block.number, rewardHistory[block.number]);
                return _tBalanceAdded;
            }
        }
        emit Rebase(block.number, 0);
        return 0;
    }




    function rewardBlocksLength() external view returns (uint256){
        return rewardBlocks.length;
    }

}
