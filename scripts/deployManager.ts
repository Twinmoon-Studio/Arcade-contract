import { ethers, upgrades } from "hardhat";

async function main() {
  const accounts = await ethers.provider.listAccounts();
  console.log("Accounts[0]:", accounts[0]);

  const ArcadeManager = await ethers.getContractFactory("ArcadeManagerV3");
  const managerParameter = ["0xa28Cf61504d3F5656B193C73902F012c8C608b6c","0xD76e263c8F23855d178EE7457176D8389fC1fE58"];
  // const arcadeManagerAdmin = await upgrades.deployProxyAdmin();
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
