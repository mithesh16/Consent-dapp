
import './App.css';
import { ethers } from 'ethers';
import React ,{useState}from 'react';
function App() {
  let [account,setAccount]=useState("")
  const [contract,setcontract]=useState("")
  const[isconnected,setconnected]=useState(false)
  let [data,setData]=useState("Location");
  let [rec_id,setrecid]=useState("");
  let [userid,setuserid]=useState("");
  const{ethereum}=window;

  const connectMetamask=async()=>{
    try{
    if(window.ethereum !== "undefined"){
      const accounts=await ethereum.request({method:"eth_requestAccounts"});
      setAccount(accounts[0]);
      setconnected(true);
      const provider=new ethers.providers.Web3Provider(window.ethereum);
      const signer=provider.getSigner();
      const address="0x0f574c52860c9ef327c252f87cf74cea8f28383d";
      const ABI=[
        {
          "inputs": [
            {
              "internalType": "string",
              "name": "userid",
              "type": "string"
            },
            {
              "internalType": "string",
              "name": "datatype",
              "type": "string"
            },
            {
              "internalType": "string",
              "name": "recipient",
              "type": "string"
            }
          ],
          "name": "check_consent",
          "outputs": [
            {
              "internalType": "bool",
              "name": "",
              "type": "bool"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "consentCount",
          "outputs": [
            {
              "internalType": "uint256",
              "name": "",
              "type": "uint256"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "string",
              "name": "user_id",
              "type": "string"
            },
            {
              "internalType": "string",
              "name": "datatype",
              "type": "string"
            },
            {
              "internalType": "string",
              "name": "recipient_id",
              "type": "string"
            }
          ],
          "name": "give_consent",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "string",
              "name": "userid",
              "type": "string"
            },
            {
              "internalType": "string",
              "name": "datatype",
              "type": "string"
            },
            {
              "internalType": "string",
              "name": "recipient",
              "type": "string"
            }
          ],
          "name": "revoke_consent",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "string",
              "name": "userid",
              "type": "string"
            }
          ],
          "name": "setUserID",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "address",
              "name": "",
              "type": "address"
            }
          ],
          "name": "userIds",
          "outputs": [
            {
              "internalType": "string",
              "name": "",
              "type": "string"
            }
          ],
          "stateMutability": "view",
          "type": "function"
        }
      ];
      let contracts=new ethers.Contract(address,ABI,signer);
      setcontract(contracts)

    }
    else{
      alert("Install metamask")
    }
    }
    catch(err)
    {
      alert("Install metamask")
    }
  }
  
  async function setuserID(event){
    try{
    event.preventDefault();
    const tx=await contract.setUserID(userid);
   if(tx){
    alert("Success")
   }
    }
    catch(err){
      alert(err.reason)
    }
  }
async function giveconsent(event){
  try{
  event.preventDefault();
  let callerid=await contract.userIds(account)
  const tx=await contract.give_consent(callerid,data,rec_id);
 if(tx){
  alert("Success")
 }
}
catch(err){
  alert(err.reason);
}
}
async function revokeconsent(event){
 try{
  event.preventDefault();
  let callerid=await contract.userIds(account)
  const tx=await contract.revoke_consent(callerid,data,rec_id );
 if(tx){
  alert("Success")
 }
}
catch(err){
  alert(err.reason);
}
}
async function checkconsent(event){
 try{
  event.preventDefault();
  let callerid=await contract.userIds(account)
  const tx=await contract.check_consent(callerid,data,rec_id );
  if(tx){
  alert("Consent given");
}
else{
  alert("Consent not given")
}
 }
catch(err){
  alert(err.code);
}
}



function changedata(event){
setData(event.target.value)
}
function changeid(event){
  setrecid(event.target.value)
  }
function changeUserId(event){
  setuserid(event.target.value)
}



  return (
    <div className="App">
     <header>  
       <h1>Consent CRED</h1> 
      <div>{!isconnected? (<button className='connect' onClick={connectMetamask}>Connect</button>):(<h2>Connected</h2>)}
      <h3>{account}</h3></div>  
     </header>
  <br/>
    <div className="userid-form">
      <h2>Set UserId</h2>
      <form onSubmit={setuserID}>
      <label>User Id:</label>
        <input placeholder='Enter UserId' onChange={changeUserId}/><br/><br/>
        <button type="submit">Set UserId</button>
      </form>
    </div>
    <br/>
    <br/>

<div className='consent-form'>
<h2>Consent</h2>
     <form>
      <label>Recipient Id:</label>
      <input type="text" placeholder='Enter recipient id' onChange={changeid}/><br/><br/>
     <label>DataType:</label>
        <select name="DataType" id="datatypes" onChange={changedata}>
      <option value="Location">Location</option>
      <option value="Personal Details">Personal Details</option>
      <option value="Health info">Health info</option>
    <option value="Purchase History">Purchase History</option>
</select>
<br/>
<br/>
<button type="submit" onClick={giveconsent}>Submit</button> <button type="submit" onClick={revokeconsent}>Revoke</button> <button type="submit" onClick={checkconsent}>Check</button>
     </form>
       
</div>
</div>
  );
}

export default App;
