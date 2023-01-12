
const hre = require("hardhat");

async function main() {
  
  const contracts = await hre.ethers.getContractFactory("ConsentCred");
  const contract = await contracts.deploy();
  const accounts = await ethers.getSigners();
  owner=accounts[0]
  console.log(owner.address)
  await contract.deployed();
  console.log(contract.address);

  tx=await contract.setUserID("mithesh");
  userid=await contract.userIds(owner.address)
   tx2=await contract.give_consent(userid,"location","kakashi");
   tx3=await contract.check_consent(userid,"location","kakashi");
   console.log(tx3)
  tx4=await contract.revoke_consent(userid,"location","kakashi");
   tx3=await contract.check_consent(userid,"location","kakashi");
   console.log(tx3)
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
