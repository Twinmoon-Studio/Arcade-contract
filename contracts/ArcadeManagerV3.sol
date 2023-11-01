// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "contracts/ArcadeVaultV3.sol";

contract ArcadeManagerV3 is Initializable, UUPSUpgradeable, OwnableUpgradeable{
    
    address payable public manager;
    ArcadeVaultV3 public vault;
    mapping (address => uint32) shares;
    address [] public holders;
    uint256 public length;

    event RemoveShare(address _o, uint256 _timestamp);
    event AddShare(address _o, uint32 _shares, uint256 _tiemstamp);
    event SetManager(address payable _o, address payable _m, uint256 _timestamp);
    event SetVault(address _o, address _a, uint256 _timestamp);
    event ShareStableProfit(uint256 _a, uint256 _timestamp);
    event ShareBonkProfit(uint256 _a, uint256 _timestamp);

    function initialize(address payable _manager, address _v) public initializer {
        manager = _manager;
        vault = ArcadeVaultV3(_v);
        length = 0;
        __Ownable_init();
   }

   function _authorizeUpgrade(address) internal override onlyOwner {}

   function addShares(address _o, uint32 _shares) external onlyOwner {
       holders.push(_o);
       shares[_o] = _shares;
       length += 1;
       emit AddShare(_o, _shares, block.timestamp);
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
        emit RemoveShare(_o, block.timestamp);
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
       emit SetManager(manager, _m, block.timestamp);
       manager = _m;
   }

   function setVault(address _a) external onlyOwner {
       emit SetVault(address(vault), _a, block.timestamp);
       vault = ArcadeVaultV3(_a);
   }

    function shareStableProfit() external onlyOwner {
        uint256 stableReserve = vault.getStableReserve();
        for (uint64 i = 0; i < holders.length; i++) {
            address m = holders[i];
            uint256 s = shares[m];
            uint256 amount = stableReserve * s / 10_000;
            vault.withdrawStableFromReserve(m, amount);
        }
        emit ShareStableProfit(stableReserve, block.timestamp);
    }

    function shareBonkProfit() external onlyOwner {
        uint256 bonkReserve = vault.getBonkReserve();
         for (uint64 i = 0; i < holders.length; i++) {
            address m = holders[i];
            uint256 s = shares[m];
            uint256 amount = bonkReserve * s / 10_000;
            vault.withdrawBonkFromReserve(m, amount);
        }
        emit ShareBonkProfit(bonkReserve, block.timestamp);
    }

}
