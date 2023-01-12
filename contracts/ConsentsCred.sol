// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
contract ConsentCred{
    
    struct Consent{
        uint consentId;
        string dataType;
        string holder;
        string recipient;
        bool consented;
    }

    uint public consentCount;
    mapping(uint=>Consent)private  consents;
    mapping(string=>uint[])private userConsents;
    mapping(address=>string) public userIds;


    function give_consent(string calldata user_id,string calldata datatype,string calldata recipient_id)external{
          bool check = comparestrings(userIds[msg.sender],user_id);
        require(check,"only holder can give consent");
        require(bytes(user_id).length <=10,"Length should not exceed 10 characters");
        require(bytes(recipient_id).length <=10,"Length should not exceed 10 characters");
        uint consentid=get_consentid(user_id,datatype,recipient_id);
        if(consentid==0){
        consentCount++;
        Consent memory consent=Consent(
            {
                consentId:consentCount,
                dataType:datatype,
                holder:user_id,
                recipient:recipient_id,
                consented:true
            }
        );
        consents[consentCount]=consent;
        userConsents[user_id].push(consentCount);
    }
    else{
        consents[consentid].consented=true;
    }
    }
    function setUserID(string calldata userid)external {
        require(keccak256(abi.encodePacked(userIds[msg.sender])) == keccak256(abi.encodePacked('')),"Already set");
        require(bytes(userid).length <=100,"Length should not exceed 10 characters");
        userIds[msg.sender]=userid;
    }

    function comparestrings(string memory s1,string memory s2) internal pure returns (bool){
         if(keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2))){
             return true;
         }
         else{
             return false;
         }
    }

    function check_consent(string calldata userid,string calldata datatype,string calldata recipient)external view returns(bool) {
        uint consentid=get_consentid(userid,datatype,recipient);
        return consents[consentid].consented;
        
    }
    
    function get_consentid(string calldata userid,string calldata datatype,string calldata recipient)internal view returns(uint){
         uint flag;
        uint[] memory consentarray=userConsents[userid];
        for(uint i=0;i<consentarray.length;i++){
        bool check=comparestrings(consents[consentarray[i]].recipient,recipient);
        bool check2=comparestrings(consents[consentarray[i]].dataType,datatype);
        if(check && check2){
            flag=consents[consentarray[i]].consentId;
            break;
        }
        else{
            flag= 0;
        }
        }
         return flag;
    }

    function revoke_consent(string calldata userid,string calldata datatype,string calldata recipient)external {
        bool check = comparestrings(userIds[msg.sender],userid);
        require(check,"only holder can revoke consent");
         uint consentid=get_consentid(userid,datatype,recipient);
         require(consents[consentid].consented,"Already revoked");
         consents[consentid].consented=false;

    }


}