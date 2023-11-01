// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "contracts/ArcadeManagerV3.sol";

contract ArcadeVaultV3 is Initializable, UUPSUpgradeable, OwnableUpgradeable{
    
    using SafeERC20 for IERC20;
    IERC20 public bonkToken;
    IERC20 public stableToken;
    uint256 public bonkSupply;
    uint256 public stableSupply;
    uint256 public bonkReserve;
    uint256 public stableReserve;

    // Reserve public reserves;
    ArcadeManagerV3 public manager;
    address public exchangeCenter;

    event SetExchange(address _o, address _n, uint256 _timestamp);
    event SetStableToken(address _o, address _n, uint256 _timestamp);
    event SetBonkToken(address _o, address _n, uint256 _timestamp);
    event DepositStable(uint256 _a, uint256 _timestamp);
    event DepositBonk(uint256 _a, uint256 _timestamp);
	event TransferStable(address _u, uint256 _a, uint256 _timestamp);
	event TransferBonk(address _u, uint256 _a, uint256 _timestamp);
	event WithdrawStableFromReserve(address _u, uint256 _a, uint256 _timestamp);
	event WithdrawBonkFromReserve(address _u, uint256 _a, uint256 _timestamp);
	event WithdrawStable(address _u, uint256 _a, uint256 _timestamp);
	event WithdrawBonk(address _u, uint256 _a, uint256 _timestamp);
	event SetManager(address _o, address _m, uint256 _timestamp);


    function initialize(address _manager, address _exc, address _bonkToken, address _usdtToken, uint256 _bs, uint256 _usdts, uint256 _brsv, uint256 _stbrsv) public initializer {
        bonkToken = IERC20(_bonkToken);
        stableToken = IERC20(_usdtToken);
        bonkSupply = _bs;
        stableSupply = _usdts;
        bonkReserve = _brsv;
        stableReserve = _stbrsv;
        manager = ArcadeManagerV3(_manager);
        exchangeCenter = _exc;
        __Ownable_init();
   }

   function _authorizeUpgrade(address) internal override onlyOwner {}

    modifier onlyManager {
        bool check = manager.checkManager(msg.sender);
        bool checkExchange;
        if (check || msg.sender == exchangeCenter) {
            _;
        } else {
            revert("You are not authorized");
        }
    }

    function validateBonkSupply(uint256 _a) internal view returns (bool) {
        if (_a <= bonkSupply) {
            return true;
        } 
        return false;
    }

    function validateStableSupply(uint256 _a) internal view returns (bool) {
        if (_a <= stableSupply) {
            return true;
        }
        return false;
    }

    function updateStableReserve(uint256 _amount) external onlyManager returns (bool _r) {
        stableReserve += _amount;
        return true;
    }

    function updateBonkReserve(uint256 _amount) external onlyManager returns (bool _r) {
        
        bonkReserve += _amount;
        return true;
    }

    function updateStableSupply(uint256 _amount) external onlyManager returns (bool _r) {
        stableSupply += _amount;
        return true;
    }

    function updateBonkSupply(uint256 _amount) external onlyManager returns (bool _r) {
        bonkSupply += _amount;
        return true;
    }

    function getStableToken() external view returns (address) {
        address stable = address(stableToken);
        return stable;
    }

    function getBonkToken() external view returns (address) {
        address bonk = address(bonkToken);
        return bonk;
    }

    function getStableSupply() external view returns (uint256) {
        return stableSupply;
    }

    function getBonkSupply() external view returns (uint256) {
        return bonkSupply;
    }


    function getStableReserve() external view returns (uint256) {
        return stableReserve;
    }

    function getBonkReserve() external view returns (uint256) {
        return bonkReserve;
    }

    function checkStableSupply(uint256 _a) external view returns (bool _r) {
        if (_a <= stableSupply) {
            return true;
        }
        return false;
    }
    
    function checkBonkSupply(uint256 _a) external view returns (bool _r) {
        if (_a <= bonkSupply) {
            return true;
        }
        return false;
    }

    function setExchange(address _e) external onlyOwner {
        emit SetExchange(exchangeCenter, _e, block.timestamp);
        exchangeCenter = _e;
    }

    function setStableToken(address _a) external onlyOwner {
        emit SetStableToken(address(stableToken), _a, block.timestamp);
        stableToken = IERC20(_a);
    }

    function setBonkToken(address _a) external onlyOwner {
        emit SetBonkToken(address(bonkToken), _a, block.timestamp);
        bonkToken = IERC20(_a);
    }

    function depositStable(uint256 _a) external {
        stableToken.safeTransferFrom(msg.sender, address(this), _a);
        stableSupply += _a;
        emit DepositStable(_a, block.timestamp);
    }

    function depositBonk(uint256 _a) external {
        bonkToken.safeTransferFrom(msg.sender, address(this), _a);
        bonkSupply += _a;
        emit DepositBonk(_a, block.timestamp);
    }

    function transferStable(address _u, uint256 _a) external onlyManager {
        bool check = validateStableSupply(_a);
        if (!check) {
            revert("Not Available");
        }
        stableToken.safeTransfer(_u, _a);
        stableSupply -= _a;
        emit TransferStable(_u, _a, block.timestamp);
    }

    function transferBonk(address _u, uint256 _a) external onlyManager {
        bool check = validateBonkSupply(_a);
        if (!check) {
            revert("Not Available");
        }
        bonkToken.safeTransfer(_u, _a);
        bonkSupply -= _a;
        emit TransferBonk(_u, _a, block.timestamp);
    } 


    function withdrawStableFromReserve(address _u, uint256 _a) external onlyManager {
        if (stableReserve > _a) {
            revert("Cannot Withderaw");
        }
        stableToken.safeTransfer(_u, _a);
        stableReserve -= _a;
        stableSupply -= _a;
        emit WithdrawStableFromReserve(_u, _a, block.timestamp);
    }
    

    function withdrawBonkFromReserve(address _u, uint256 _a) external onlyManager {
        if (bonkReserve > _a) {
            revert ("Cannot Withdraw");
        }
        bonkToken.safeTransfer(_u, _a);
        bonkReserve -= _a;
        bonkSupply -= _a;
        emit WithdrawBonkFromReserve(_u, _a, block.timestamp);
    }


    function withdrawStable(address _u, uint256 _a) external onlyOwner returns (bool) {
        bool check = validateStableSupply(_a);
        if (!check) {
            revert("No Supply Available");
        }
        stableToken.safeTransfer(_u,_a);
        stableSupply -= _a;
        stableReserve = 0;
        emit WithdrawStable(_u, _a, block.timestamp);
        return true;
    }

    function withdrawBonk(address _u, uint256 _a) external onlyOwner returns (bool) {
        bool check = validateBonkSupply(_a);
        if (!check) {
            revert("No Supply Available");
        }
        bonkToken.safeTransfer(_u,_a);
        bonkSupply -= _a;
        bonkReserve = 0;
        emit WithdrawBonk(_u, _a, block.timestamp);
        return true;
    }

   function setManager(address _m) external onlyOwner {
       emit SetManager(address(manager), _m, block.timestamp);
       manager = ArcadeManagerV3(_m);
   }
}
