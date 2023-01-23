const hre = require("hardhat");

async function main() {

//#region Executors Contract
  /*
  const Exec = await hre.ethers.getContractFactory("StickExecutors");
  const exec = await Exec.deploy();

  await exec.deployed();

  console.log(`The contract deployed to ${exec.address}`);
  //*/
//#endregion

//#region DAO Contract
  
const DAO = await hre.ethers.getContractFactory("StickDAO");
const dao = await DAO.deploy();

await dao.deployed();

console.log(`The contract deployed to ${dao.address}`);
//*/
//#endregion


}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
