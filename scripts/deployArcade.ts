import { ethers, upgrades } from "hardhat";

async function main() {
  // const ArcadeManager = await ethers.getContractFactory("ArcadeManager"); //
  const ArcadeVault = await ethers.getContractFactory("ArcadeVaultV3");
  const ArcadeExchange = await ethers.getContractFactory("ArcadeExchangeV3");

  // const managerParameter = ["0x2A88e5E5Cf0DD6Be32d8FC66c85aF4ee65553D8D"];

  // const arcadeManager = await upgrades.deployProxy(
  //   ArcadeManager,
  //   managerParameter
  // );
  // await arcadeManager.deployed();

  // console.log("Arcade Manager deployed to:", arcadeManager.address);

  const arcadeManagerAddr = "0x4caf32287aad93e80DAaCAdB6FB72b2b83a137D4";
  const exchangeParameter = [
    arcadeManagerAddr,
    "0x2A88e5E5Cf0DD6Be32d8FC66c85aF4ee65553D8D",
    2,
    1000,
  ];
  const arcadeExchange = await upgrades.deployProxy(
    ArcadeExchange,
    exchangeParameter
  );
  await arcadeExchange.deployed();

  console.log("Arcade Exchange deployed to: ", arcadeExchange.address);
  const vaultParameter = [
    arcadeManagerAddr,
    arcadeExchange.address,
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
