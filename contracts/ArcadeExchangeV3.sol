// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "contracts/ArcadeManagerV3.sol";
import "contracts/ArcadeVaultV3.sol";

contract ArcadeExchange is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    enum EXCHANGE_LIST { BONK_TO_USDT, USDT_TO_BONK, BONK_TO_BAM, BAM_TO_BONK }
    using SafeERC20 for IERC20;
    ArcadeVaultV3 public vault;
    ArcadeManagerV3 public manager;
    uint16 public bonkPrice;
    uint16 public bamPrice;
    uint256 public interestRate;

    event UpdateBonkMarketPrice(uint256 _op, uint256 _np, uint256 _timestamp);
    event UpdateBamPrice(uint16 _op, uint16 _np, uint256 _timestamp);
    event SetVault(address _ov, address _nv, uint256 _timestamp);
    event SetManager(address _om, address _nm, uint256 _timestamp);
    event SetInterestRate(uint256 _obps, uint256 _nbps, uint256 _timestamp);
    event ExchangeStableToBonk(address _r, uint256 _a, uint256 _timestamp);
    event ExchangeBonkToStable(address _r, uint256 _a, uint256 _timestamp);
    event ExchangeBonkToBam(address _r, uint256 _a, uint256 _timestamp);
    event ExchangeBamToBonk(address payable _u, uint256 _a, uint256 _timestamp);

    function initialize(address _m, address _v, uint16 _bp, uint256 _ir, uint16 _bamp) public initializer {
        manager = ArcadeManagerV3(_m);
        vault = ArcadeVaultV3(_v);
        bonkPrice = _bp;
        interestRate = _ir;
        bamPrice = _bamp;
        __Ownable_init();
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    modifier onlyManager {
        bool check = manager.checkManager(msg.sender);
        if (check) {
            _;
        } else {
           revert("You are not authorized");
        }
    }

    function validateToken(address _m, address _check) internal pure returns (bool) {
        if (_m == _check) {
            return true;
        }
        return false;
    }

    function getTokens() internal view returns (IERC20 _b ,IERC20 _u) {
        address bonkTokenAddr;
        address stableTokenAddr;
        // (bonkTokenAddr, stableTokenAddr) = vault.getTokens();
        bonkTokenAddr = vault.getBonkToken();
        stableTokenAddr = vault.getStableToken();
        
        IERC20 bonkToken = IERC20(bonkTokenAddr);
        IERC20 usdtToken = IERC20(stableTokenAddr);

        return (bonkToken, usdtToken);
    }

    function getStableToken() internal view returns (IERC20 _t) {
        address tokenAddr = vault.getStableToken();
        IERC20 token = IERC20(tokenAddr);
        return token;
    }

    function getBonkToken() internal view returns (IERC20 _t) {
        address tokenAddr = vault.getBonkToken();
        IERC20 token = IERC20(tokenAddr);
        return token;
    }

    function calculateFees(uint256 _amount) internal view returns (uint256, uint256) {
        // uint256 serviceCharge = _amount / interestRate;
        uint256 serviceCharge = _amount * interestRate / 10_000;
        uint256 totalAmount = _amount - serviceCharge;
        return (totalAmount, serviceCharge);
    }

    function calculateBonkToStable(uint256 _amount) internal view returns (uint256) {
        uint256 totalAmount = _amount * bonkPrice;
        return totalAmount;
    }

    function calculateStableToBonk(uint256 _amount) internal view returns (uint256) {
        uint256 totalAmount = _amount / bonkPrice;
        return totalAmount;
    }

    function calculateBam(uint256 _amount) internal view returns (uint256) {
        uint256 totalAmount = _amount * bamPrice;
        return totalAmount;
    }

    function updateBonkMarketPrice(uint16 _amount) external onlyManager {
        emit UpdateBonkMarketPrice(bonkPrice, _amount, block.timestamp);
        bonkPrice = _amount;
    }

    function updateBamPrice(uint16 _amount) external onlyManager {
        emit UpdateBamPrice(bamPrice, _amount, block.timestamp);
        bamPrice = _amount;
    }

    function setVault(address _v) onlyOwner external {
        address oldAddr = address(vault);
        emit SetVault(oldAddr, _v, block.timestamp);
        vault = ArcadeVaultV3(_v);
    }

    function setManager(address _v) onlyOwner external {
        address oldAddr = address(manager);
        emit SetManager(oldAddr, _v, block.timestamp);
        manager = ArcadeManagerV3(_v);
    }

    function setInterestRate(uint256 _bps) onlyManager external {
        emit SetInterestRate(interestRate, _bps, block.timestamp);
        interestRate = _bps;
    }

    function getManager() external view returns (address payable) {
        address payable mng = manager.manager();
        return mng;
    }

    function getBamPrice() external view returns (uint16 _a) {
        return bamPrice;
    }

    function exchangeStableToBonk(uint256 _a) external returns (bool){
        uint256 totalAmount;
        uint256 serviceCharge;
        (totalAmount, serviceCharge) = calculateFees(_a);
        uint256 estimate = calculateStableToBonk(totalAmount);
        bool check = vault.checkBonkSupply(estimate);
        if (check) {
            address stableAddr = vault.getStableToken();
            IERC20 stableToken = IERC20(stableAddr);
            stableToken.safeTransferFrom(msg.sender, address(vault), _a);
            // Update stable token supply and reserve
            vault.updateStableSupply(_a);
            vault.updateStableReserve(serviceCharge);
            // Transfer bonk token to sender
            vault.transferBonk(msg.sender, estimate);
            emit ExchangeStableToBonk(msg.sender, _a, block.timestamp);
            return true;   
        }
        return false;
    } 

    function exchangeBonkToStable(uint256 _a) external returns (bool) {
        uint256 totalAmount;
        uint256 serviceCharge;
        (totalAmount, serviceCharge) = calculateFees(_a);
        uint256 estimate = calculateBonkToStable(totalAmount);
        bool check = vault.checkStableSupply(estimate);
        if (check) {
            address bonkAddr = vault.getBonkToken();
            IERC20 bonkToken  = IERC20(bonkAddr);
            bonkToken.safeTransferFrom(msg.sender, address(vault), _a);
            // Update bonk token supply and reserve
            vault.updateBonkSupply(_a);
            vault.updateBonkReserve(serviceCharge);
            // Transfer stable token to sender
            vault.transferStable(msg.sender, estimate);
            emit ExchangeBonkToStable(msg.sender, _a, block.timestamp);
            return true;   
        }
        return false;
    }

    function exchangeBonkToBam(uint256 _a) external returns (bool) {
        uint256 totalAmount;
        uint256 serviceCharge;
        (totalAmount, serviceCharge) = calculateFees(_a);
        address bonkAddr = vault.getBonkToken();
        IERC20 bonkToken = IERC20(bonkAddr);
        bonkToken.safeTransferFrom(msg.sender, address(vault), _a);
        // Update bonk token supply and reserve
        vault.updateBonkSupply(_a);
        vault.updateBonkReserve(serviceCharge);
        emit ExchangeBonkToBam(msg.sender, _a, block.timestamp);
        return true;
    }

    function exchangeBamToBonk(address payable _u, uint256 _a) external onlyManager returns (bool) {
        bool check = vault.checkBonkSupply(_a);
        if (check) {
            vault.transferBonk(_u, _a);
            emit ExchangeBamToBonk(_u, _a, block.timestamp);
            return true;
        }
        return false;
    }

    // function delegateRewards(address payable _u, uint256 _amount) external onlyManager returns (bool) {
    //     bool check = vault.checkSupplies(TOKEN_CHOICE.BONK, _amount);
    //     if (check) {
    //         vault.exchangeTransfer(TOKEN_CHOICE.BONK, _u, _amount);
    //         return true;
    //     }
    //     return false;
    // }

    function estimateFees(uint256 _amount) external view returns (uint256, uint256) {
        uint256 serviceCharge = _amount * interestRate / 10_000;
        uint256 totalAmount = _amount - serviceCharge;
        return (totalAmount, serviceCharge);
    }
    
}
