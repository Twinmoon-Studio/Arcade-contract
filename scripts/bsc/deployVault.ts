import { ethers, upgrades } from "hardhat";

async function main() {
  const ArcadeVault = await ethers.getContractFactory("ArcadeVaultV2");
  const vaultParameter = [
    "0x2399b02e5f2c6517c79ece1243784598f4caa3fb",
    "0x61102B0442FB91850f13cAF6edB5bDd7A8931065",
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
