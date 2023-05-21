import { ethers, upgrades } from "hardhat";

async function main() {
  const BonkToken = await ethers.getContractFactory("BONKToken");
  const bonkToken = await upgrades.deployProxy(BonkToken, [], {
    initializer: "initialize",
    kind: "transparent",
  });

  await bonkToken.deployed();
  console.log("Owner: ", await bonkToken.owner());
  console.log("Bonk Token deployed to: ", bonkToken.address);
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
