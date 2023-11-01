import { ethers, upgrades } from "hardhat";

async function main() {
  const ArcadeExchange = await ethers.getContractFactory("ArcadeExchange");
  const exchangeParameter = [
    "0x810460c565c52c368500Ca527728868200495210",
    "0x6b210bd7d660541AA179dAe20bF907392469668e",
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
