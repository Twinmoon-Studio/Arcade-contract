import { ethers, upgrades } from "hardhat";

async function main() {
  const ArcadeVault = await ethers.getContractFactory("ArcadeVaultV2");
  const vaultParameter = [
    "0xFF4D502Eaec6828a92159A4E55dc686dEA3bDaDa",
    "0x4dECBfe9eb0cCBBBF7b56F3E2b79C7cAD3C264a5",
    "0x85096BBfC0A45710b0241fC62dd07f9c9004bdC6",
    "0xeD145dd74ED7493FC8756355dE84C0Daf795a8ED",
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
