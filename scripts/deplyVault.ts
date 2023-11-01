import { ethers, upgrades } from "hardhat";

async function main() {
  const ArcadeVault = await ethers.getContractFactory("ArcadeVaultV3");
  const vaultParameter = [
    "0x810460c565c52c368500Ca527728868200495210",
    "0x656BceFc84d4C694D2193811fc34F49e020481Be",
    "0xBe755Ac37FB7a2eaF67B95F1d7Bc8A9cF08dAE98",
    "0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56",
    0,
    0,
    0,
    0,
  ];

  const arcadeVault = await upgrades.deployProxy(ArcadeVault, vaultParameter);
  await arcadeVault.deployed();

  console.log("Arcade Vault deployed to :", arcadeVault.address);
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
