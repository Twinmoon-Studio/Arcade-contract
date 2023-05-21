// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

// import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/safeERC20Upgradeable.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";

// import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "contracts/ArcadeManager.sol";

// enum TOKEN_CHOICE { BONK, USDT, OTHERS }

contract ArcadeVaultV2 is Initializable, UUPSUpgradeable, OwnableUpgradeable{
    
    using SafeERC20 for IERC20;

    // Asset public assets;
    IERC20 public bonkToken;
    IERC20 public stableToken;
    uint256 public bonkSupply;
    uint256 public stableSupply;
    // Supply public supplies;
    uint256 public bonkReserve;
    uint256 public stableReserve;
    // Reserve public reserves;
    ArcadeManager public manager;
    address public exchangeCenter;

    function initialize(address _manager, address _exc, address _bonkToken, address _usdtToken, uint256 _bs, uint256 _usdts, uint256 _brsv, uint256 _usdtrsv) public initializer {
        // assets.bonkToken = IERC20(_bonkToken);
        bonkToken = IERC20(_bonkToken);
        stableToken = IERC20(_usdtToken);
        bonkSupply = _bs;
        stableSupply = _usdts;
        bonkReserve = _brsv;
        stableReserve = _usdtrsv;
        manager = ArcadeManager(_manager);
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

   function validateSupplies(TOKEN_CHOICE _t, uint256 _a) internal view returns (bool) {
       if (_t == TOKEN_CHOICE.BONK) {
           if (_a > bonkSupply) {
               return false;
           }
           return true;
       } else if (_t == TOKEN_CHOICE.USDT) {
           if (_a > stableSupply) {
               return false;
           }
           return true;
       }
       return false;
   }

   function updateReserves(TOKEN_CHOICE _t, uint256 _amount) external onlyManager returns (bool _r) {
       if (_t == TOKEN_CHOICE.BONK) {
           bonkReserve += _amount;
           return true;
        } else if (_t == TOKEN_CHOICE.USDT) {
            stableReserve += _amount;
            return true;
        }
        return false;
   }

   function updateSupplies(TOKEN_CHOICE _t, uint256 _amount) external onlyManager returns (bool _r) {
       if (_t == TOKEN_CHOICE.BONK) {
           bonkSupply += _amount;
           return true;
       } else if (_t == TOKEN_CHOICE.USDT) {
           stableSupply += _amount;
           return true;
       }
       return false;
   }

   function getTokens() external view returns (address, address) {
       address bonk = address(bonkToken);
       address usdt = address(stableToken);
       return (bonk,usdt);
   }

   function getSupplies() external view returns (uint256, uint256) {
       return (bonkSupply, stableSupply);
   }

   function getReserves() external view returns (uint256, uint256) {
       return (bonkReserve, stableReserve);
    }

    function checkSupplies(TOKEN_CHOICE _t, uint256 _a) external view returns (bool _r) {
        if (_t == TOKEN_CHOICE.BONK && _a <= bonkSupply) {
            return true;
        } else if (_t == TOKEN_CHOICE.USDT && _a <= stableSupply) {
            return true;
        }
        return false;
    }

    function setExchange(address _e) external onlyOwner {
        exchangeCenter = _e;
    }

    function setToken(TOKEN_CHOICE _t, address _a) external onlyOwner {
        if (_t == TOKEN_CHOICE.BONK) {
            bonkToken = IERC20(_a);
        } else if (_t == TOKEN_CHOICE.USDT) {
            stableToken = IERC20(_a);
        } else {
        revert("Token not available");
        }
    }

    function deposit(TOKEN_CHOICE _t, uint256 _a) external {
        if (_t == TOKEN_CHOICE.BONK) {
            bonkToken.safeTransferFrom(msg.sender, address(this), _a);
            bonkSupply += _a;
        } else if (_t == TOKEN_CHOICE.USDT) {
            stableToken.safeTransferFrom(msg.sender, address(this), _a);
            stableSupply += _a;
        }
    }

    function exchangeTransfer(TOKEN_CHOICE _t, address _u, uint256 _a) external onlyManager {
       bool check = validateSupplies(_t, _a);
       if (!check) {
           revert("Not Available!");
       } 
       if (_t == TOKEN_CHOICE.BONK) {
           bonkToken.safeTransfer(_u,_a);
           bonkSupply -= _a;
       } else if (_t == TOKEN_CHOICE.USDT) {
           stableToken.safeTransfer(_u,_a);
           stableSupply -= _a;
       } else {
        revert("Cannot withdraw");       
       }
   }

   function withdrawFromReserve(TOKEN_CHOICE _t, address _u, uint256 _a) external onlyManager {
    //    uint256 bonkReserve = bonkReserve;
    //    uint256 usdtReserve = reserves.usdtReserve;
       if (_t == TOKEN_CHOICE.BONK && _a <= bonkReserve) {
           bonkToken.safeTransfer(_u, _a);
           bonkReserve -= _a;
           bonkSupply -= _a;
       } else if (_t == TOKEN_CHOICE.USDT && _a <= stableReserve) {
           stableToken.safeTransfer(_u,_a);
           stableReserve -= _a;
           stableSupply -= _a;
       } else {
           revert("Cannot Withdraw");
       }
   }

   function withdraw(TOKEN_CHOICE _t, address _u, uint256 _a) external onlyOwner {
        bool check = validateSupplies(_t, _a);
        if (!check) {
            revert("No Supply Available");
        }
        if (_t == TOKEN_CHOICE.BONK) {
            bonkToken.safeTransfer(_u,_a);
            bonkSupply -= _a;
            bonkReserve = 0;
        } else if (_t == TOKEN_CHOICE.USDT) {
            stableToken.safeTransfer(_u,_a);
            stableSupply -= _a;
            stableReserve = 0;
        } else {
            revert("Cannot withdraw");
        }
   }

   function setManager(address _m) external onlyOwner {
       manager = ArcadeManager(_m);
   }
}
