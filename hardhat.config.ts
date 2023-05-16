import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";

import { config as dotEnvConfig } from "dotenv";
dotEnvConfig();

const mnemonicCode = process.env.MNEMONIC ?? "NO_CODE";
// const bscscanKey = "ZD8K7QVDY32C6T9EVKV5XCKPQXVZG8JM6Q";
const bscscanKey = process.env.BSCSCAN_KEY ?? "";

const config: HardhatUserConfig = {
  solidity: "0.8.18",
  etherscan: { apiKey: bscscanKey },
  networks: {
    tsc: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      chainId: 97,
      blockGasLimit: 8e9,
      gasPrice: 20e9,
      gas: 25e6,
      accounts: { mnemonic: mnemonicCode },
    },
    bsc: {
      url: "https://bsc-dataseed.binance.org/",
      accounts: {
        mnemonic: mnemonicCode,
      },
      chainId: 56,
      blockGasLimit: 8e9,
      gasPrice: 20e9,
      gas: 25e6,
    },
  },
};

export default config;
