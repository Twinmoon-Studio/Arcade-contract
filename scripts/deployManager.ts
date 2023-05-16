import { ethers, upgrades } from "hardhat";

async function main() {
  const accounts = await ethers.provider.listAccounts();
  console.log("Accounts[0]:", accounts[0]);

  const ArcadeManager = await ethers.getContractFactory("ArcadeManager");
  const managerParameter = ["0x2A88e5E5Cf0DD6Be32d8FC66c85aF4ee65553D8D"];
  const arcadeManagerAdmin = await upgrades.deployProxyAdmin();
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
