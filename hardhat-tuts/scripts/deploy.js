// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.

const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });
const { CRYPTO_DEVS_NFT_CONTRACT_ADDRESS } = require("../constants/index");

async function main() {
  // Address of the Crypto Devs NFT contract that you deployed in the previous module

  const cryptoDevsTokenContract = await ethers.getContractFactory(
    "CryptoDevToken"
  );

  const deployCrytoDevsTokenContract = await cryptoDevsTokenContract.deploy(
    CRYPTO_DEVS_NFT_CONTRACT_ADDRESS
  );

  console.log(
    "CrytoDev Token Contract Address:",
    deployCrytoDevsTokenContract.address
  );
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });
