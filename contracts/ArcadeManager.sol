// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

// import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
// import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "contracts/ArcadeVault.sol";

contract ArcadeManager is Initializable, UUPSUpgradeable, OwnableUpgradeable{
    
    address payable public manager;
    ArcadeVault public vault;
    mapping (address => uint32) shares;
    address [] public holders;
    uint256 public length;

    function initialize(address payable _manager, address _v) public initializer {
        manager = _manager;
        vault = ArcadeVault(_v);
        length = 0;
        __Ownable_init();
   }

   function _authorizeUpgrade(address) internal override onlyOwner {}

   function addShares(address _o, uint32 _shares) external onlyOwner {
       holders.push(_o);
       shares[_o] = _shares;
       length += 1;
   } 

   modifier onlyAuthorized() {
       _;
   }

   function findIndex(address _f) internal view returns (uint256 ret) {
    address[] memory replica = holders;
       for (uint256 i = 0; i < replica.length; i++) {
           if (replica[i] == _f) {
               return i;
           }
       }
   } 

   function removeShare(address _o) external onlyOwner returns (bool b){
       if (length == 0) return false;
       uint256 find = findIndex(_o);
        for (uint i = find; i<holders.length-1; i++){
            holders[i] = holders[i+1];
        }
        delete holders[holders.length-1];
        return true;
   }

   function checkManager(address _o) external view returns (bool) {
       address convert = address(manager);
       if (_o == convert) {
           return true;
       } 
       return false;
   }

   function setManager(address payable _m) external onlyOwner {
       manager = _m;
   }

   function setVault(address _a) external onlyOwner {
       vault = ArcadeVault(_a);
   }

   function shareProfit(TOKEN_CHOICE _t) external onlyOwner {
       uint256 usdtReserve;
       uint256 bonkReserve; 
       (usdtReserve,bonkReserve) = vault.getReserves();
       for (uint64 i = 0; i < holders.length; i++) {
           address m = holders[i];
           uint256 s = shares[m];
           uint256 bonkAmount = bonkReserve * s / 10_000;
           uint256 usdtAmount = usdtReserve * s / 10_000;
           if (_t == TOKEN_CHOICE.BONK) {
               vault.withdrawFromReserve(TOKEN_CHOICE.BONK, m, bonkAmount);
           } else if (_t == TOKEN_CHOICE.USDT) {
               vault.withdrawFromReserve(TOKEN_CHOICE.USDT, m, usdtAmount);
           }
       }
   }

}
