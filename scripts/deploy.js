const hre = require("hardhat");

async function main() {

//#region Executors Contract
  
  const Exec = await hre.ethers.getContractFactory("StickExecutors");
  const exec = await Exec.deploy();

  await exec.deployed();

  console.log(`The contract deployed to ${exec.address}`);
  //*/
//#endregion


}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
