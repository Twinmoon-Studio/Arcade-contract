import { ethers, upgrades } from "hardhat";

async function main() {
  const accounts = await ethers.provider.listAccounts();
  console.log("Account[0]: ", accounts[0]);
  const ArcadeManager = await ethers.getContractFactory("ArcadeManager");
  const managerParameter = [""];
  const arcadeManager = await upgrades.deployProxy(
    ArcadeManager,
    managerParameter
  );

  await arcadeManager.deployed();
  console.log("Previous owner:", await arcadeManager.owner());
  console.log("Arcade Manager deployed to:", arcadeManager.address);
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
