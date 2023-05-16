import { ethers, upgrades } from "hardhat";

async function main() {
  const ArcadeExchange = await ethers.getContractFactory("ArcadeExchange");
  const exchangeParameter = [
    "0xFF4D502Eaec6828a92159A4E55dc686dEA3bDaDa",
    "0x0000000000000000000000000000000000000000",
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
