// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";


contract sWGC is IERC20Upgradeable, OwnableUpgradeable {  
    using SafeMathUpgradeable for uint256;   

    event ExcludeFromReward(address account);
    event IncludeInReward(address account);
    event SetStakingAddress(address stakingContract);
    event DistributeRewards(uint256 amount);
   
    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcluded;
    address[] private _excluded;
    address public stakingContract;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tRewardTotal;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    function initialize(
        string memory __name,
        string memory __symbol,
        address _stakingContract,
        uint256 _totalSupply,
        uint8 __decimals  
    ) public initializer {
        __Ownable_init();
        _name = __name;
        _symbol = __symbol;
        _decimals = __decimals;        
        stakingContract=_stakingContract;
        _isExcluded[_stakingContract]=true;
        _excluded.push(_stakingContract);
        _tTotal=_totalSupply*10**__decimals;
        _rTotal= (MAX - (MAX % _tTotal));
        _rOwned[_stakingContract] = _rTotal;
        _tOwned[_stakingContract] = _tTotal;
        emit Transfer(address(0), _stakingContract, _tTotal);
    }    

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function decimals() external view returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function isExcludedFromReward(address account)
        external
        view
        returns (bool)
    {
        return _isExcluded[account];
    }

    function totalRewards() external view returns (uint256) {
        return _tRewardTotal;
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromReward(address account) public onlyOwner {
        require(!_isExcluded[account], "Account is already excluded");
        require(
            _excluded.length + 1 <= 50,
            "Cannot exclude more than 50 accounts.  Include a previously excluded address."
        );
        if (_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
        emit ExcludeFromReward(account);
    }

    function includeInReward(address account) public onlyOwner {
        require(_isExcluded[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
        emit IncludeInReward(account);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _rOwned[_excluded[i]] > rSupply ||
                _tOwned[_excluded[i]] > tSupply
            ) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function setStakingAddress(address _stakingContract) external onlyOwner {
        require(
            _stakingContract != address(0),
            "staking address can not be 0 address!"
        );
        stakingContract = _stakingContract;
        excludeFromReward(stakingContract);
        emit SetStakingAddress(_stakingContract);
    }

    function transferForeignToken(address _token, address _to)
        external
        onlyOwner
        returns (bool _sent)
    {
        require(_token != address(this), "Can't withdraw native tokens");
        uint256 _contractBalance = IERC20Upgradeable(_token).balanceOf(address(this));
        _sent = IERC20Upgradeable(_token).transfer(_to, _contractBalance);
    }

    function distributeRewards(uint256 amount)
        external
        returns (bool _sent)
    {
        require(_isExcluded[_msgSender()], "not allowed");
        require(amount > 0 && amount<balanceOf(_msgSender()), "No balance for reward");
        _tOwned[_msgSender()]=_tOwned[_msgSender()].sub(amount);
        _tRewardTotal=_tRewardTotal.add(amount);
        emit DistributeRewards(amount);
        _sent=true;

    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 currentRate = _getRate();
        uint256 rAmount = amount.mul(currentRate);
        if (_isExcluded[from] && !_isExcluded[to]) {
            _transferFromExcluded(from, to, amount, rAmount);
        } else if (!_isExcluded[from] && _isExcluded[to]) {
            _transferToExcluded(from, to, amount, rAmount);
        } else if (_isExcluded[from] && _isExcluded[to]) {
            _transferBothExcluded(from, to, amount, rAmount);
        } else {
            _transferStandard(from, to, amount, rAmount);
        }
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount, 
        uint256 rAmount
    ) private {
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rAmount);
        emit Transfer(sender, recipient, tAmount);
    }

    function _transferToExcluded(
        address sender,
        address recipient,
        uint256 tAmount, 
        uint256 rAmount
    ) private {
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rAmount);
        emit Transfer(sender, recipient, tAmount);
    }

    function _transferFromExcluded(
        address sender,
        address recipient,
        uint256 tAmount, 
        uint256 rAmount
    ) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rAmount);
        emit Transfer(sender, recipient, tAmount);
    }

    function _transferBothExcluded(
        address sender,
        address recipient,
        uint256 tAmount, 
        uint256 rAmount
    ) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _tOwned[recipient] = _tOwned[recipient].add(tAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rAmount);
        emit Transfer(sender, recipient, tAmount);
    }

    receive() external payable {}

}
