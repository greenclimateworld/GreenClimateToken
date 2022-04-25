//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


// interface IERC20 {
//     function transfer(address to, uint256 value) external returns (bool);
//     function transferFrom(address from, address to, uint256 value) external returns (bool);
//     function balanceOf(address account) external view returns (uint256);
// }


contract WGCWrapper is Ownable{
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    IERC20 public oldToken;
    IERC20 public newToken;
    event Exchange(address account, uint256 amount);
    event TokenSet(address old_token, address new_token);    
    constructor (
        address old_token,
        address new_token
    ){
        oldToken=IERC20(old_token);
        newToken=IERC20(new_token);    
        emit TokenSet(old_token, new_token);       
    }
    function updateToken(
        address old_token,
        address new_token
    ) public onlyOwner {
        oldToken=IERC20(old_token);
        newToken=IERC20(new_token);   
        emit TokenSet(old_token, new_token);     
    }

    function exchange(
        uint256 amount
    ) public {
        require(newToken.balanceOf(address(this))>=amount, "No enough balance");
        uint256 beforeBalance=oldToken.balanceOf(address(this));
        oldToken.transferFrom(msg.sender, address(this), amount);
        uint256 balanceAdded=oldToken.balanceOf(address(this)).sub(beforeBalance);
        newToken.transfer(msg.sender, balanceAdded);
        emit Exchange(msg.sender, balanceAdded);
    }
}