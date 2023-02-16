// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract ConsentCred{
    enum userRoles{Holder,Issuer,Verifier}


    struct Consent{
        uint consentId;
        string dataType;
        string holder;
        string recipient;
        bool consented;
    }

    struct Document{
        string Attestation;
        string Datatype;
        address Holder;
        address Issuer;
    }
    
    uint public consentCount;
    mapping (uint=>Document)public Documents;
    uint datacount;
    mapping(uint=>Consent)public consents;
    mapping(string=>uint[])private userConsents;
    mapping(address=>string) public userIds;
    mapping(string=>bool)internal isTaken;
    mapping (address=>userRoles)public UserRoles;

    function give_consent(string calldata user_id,string []calldata datatype,string calldata recipient_id)external{
          bool check = comparestrings(userIds[msg.sender],user_id);
        require(check,"only holder can give consent");
        for(uint i=0;i<datatype.length;i++){
        uint consentid=get_consentid(user_id,datatype[i],recipient_id);
        if(consentid==0){
        consentCount++;
        Consent memory consent=Consent(
            {
                consentId:consentCount,
                dataType:datatype[i],
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
    }
    function setUserID(string calldata userid,userRoles _role)external {
        require(keccak256(abi.encodePacked(userIds[msg.sender])) == keccak256(abi.encodePacked('')),"Already set");
        require(bytes(userid).length <=100,"Length should not exceed 100 characters");
        require(!isTaken[userid],"Name already taken");
        userIds[msg.sender]=userid;
        UserRoles[msg.sender]=_role;
        isTaken[userid]=true;
    }

    function comparestrings(string memory s1,string memory s2) internal pure returns (bool){
         if(keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2))){
             return true;
         }
         else{
             return false;
         }
    }

    function check_consent(string memory userid,string memory datatype,string memory recipient)internal view returns(bool) {
        uint consentid=get_consentid(userid,datatype,recipient);
        return consents[consentid].consented;
    }
    
    function get_consentid(string memory userid,string memory datatype,string memory recipient)internal view returns(uint){
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

    function revoke_consent(string calldata userid,string[] calldata datatype,string calldata recipient)external {
        bool check = comparestrings(userIds[msg.sender],userid);
        require(check,"only holder can revoke consent");
        for(uint i=0;i<datatype.length;i++){
         uint consentid=get_consentid(userid,datatype[i],recipient);
         require(consentid!=0,"Consent not given");
         require(consents[consentid].consented,"Already revoked");
         consents[consentid].consented=false;
        }
    }       
    function get_documentid(address _holder,string memory datatype,address _issuer)internal view returns(uint){
         uint flag;
        for(uint i=1;i<=datacount;i++){
        bool check=comparestrings(Documents[i].Datatype,datatype);
        bool check1=Documents[i].Holder==_holder;
        bool check2=Documents[i].Issuer==_issuer;
        bool check3=check1 && check2;
        if(check && check3){
            flag=i;
            break;
        }
        else{
            flag= 0;
        }
        }
         return flag;
    }

function IssueDocument(string calldata attestation,string calldata _Datatype,address holder)external {
      require(UserRoles[msg.sender]==userRoles.Issuer,"Not an Issuer");
      require(holder!=address(0),"enter a valid holder address");
        datacount++;
        Documents[datacount]=Document(attestation,_Datatype,holder,msg.sender);
    }
  function viewDocument(string memory _datatype,address _holder,address _issuer)external view returns (Document memory){
        require(UserRoles[msg.sender]==userRoles.Verifier,"Not a verifier");
        require(check_consent(userIds[_holder],_datatype,userIds[msg.sender]),"Consent not given");
        uint id=get_documentid(_holder,_datatype,_issuer);
        Document memory _doc = Documents[id];
        return _doc;
    }

    function showMyDocuments()external view returns(Document[]memory){
            require(datacount>0,"No documents");
            uint counter=0;
            Document[] memory _document=new Document[](datacount);
            for(uint i=0;i<datacount;i++){
            if(Documents[i+1].Holder==msg.sender){
            _document[counter]=Documents[i+1];
            counter++;
            }
        }
        return _document;
    }
    function showmyconsents()external view returns(Consent[]memory){
            require(consentCount>0,"No consents available");
            uint counter=0;
            Consent[] memory _consents=new Consent[](consentCount);
            for(uint i=0;i<consentCount;i++){
            if(comparestrings(consents[i+1].holder,userIds[msg.sender])){
            _consents[counter]=consents[i+1];
            counter++;
            }
    }
    return _consents;
    }
     
 }
