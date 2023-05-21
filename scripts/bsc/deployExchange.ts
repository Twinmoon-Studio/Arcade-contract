import { ethers, upgrades } from "hardhat";

async function main() {
  const ArcadeExchange = await ethers.getContractFactory("ArcadeExchange");
  const exchangeParameter = [
    "0x2399b02E5F2c6517c79ece1243784598f4CAA3FB",
    "0x12bCe0f924De114dAcC885fB47372680C90c606B",
    2,
    1000,
    100,
  ];
  const arcadeExchange = await upgrades.deployProxy(
    ArcadeExchange,
    exchangeParameter
  );
  await arcadeExchange.deployed();

  console.log("Arcade Exchange deployed to: ", arcadeExchange.address);
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
