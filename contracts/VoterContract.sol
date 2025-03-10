// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 < 0.9.0;
pragma experimental ABIEncoderV2;



contract VoterContract {

    address electionComision;
    address public winner;

    struct Voter {
        string name;
        uint age;
        uint voterId;
        string gender;
        uint voteCandidateId;
        address voterAddress;
    }

    struct Candidate {
        string name;
        string party;
        uint age;
        string gender;
        uint candidateId;
        address candidateAddress;
        uint votes;
    }
    
    uint nextVoterId = 1; // voter id for voters
    uint nextCandidateId = 1; // candidate ID for candidate

    uint startTime; //start time of election
    uint endTime; //end time of election

    mapping(uint => Voter) voterDetails;
    mapping(uint => Candidate) CandidateDetails; //mapping uint to our struct Candidate

    bool stopVoting;

    //constructor is decalred so that whoever deploy the smart contract is the election commissioner
    constructor() public {
        electionComision = msg.sender;
    }

     modifier isVotingOver(){
        require(endTime > block.timestamp || stopVoting == false, "Voting is over");
        _;
    }

    modifier onlyCommisioner(){
        require(electionComision== msg.sender, "Not from election commision");
        _;
    }


/*function related to candidate */

    //function to see if candidate already registered or not.
    function candidateRegister(
        string calldata _name,
        string calldata _party,
        uint _age,
        string calldata _gender
        ) external {
            require(msg.sender != electionComision, "you are from election commission");
            require(candidateVerification(msg.sender) == true, "candidate already registered");
            require(_age >= 18, "you are not eligible"); //if age is >= 18 then good, else return they are not eligible
            require(nextCandidateId < 3, "candidate registration full"); //we are only registering 2 candidates, thats why its < 3
            CandidateDetails[nextCandidateId] = Candidate(_name, _party, _age, _gender, nextCandidateId, msg.sender, 0);
            nextCandidateId++;
        }

    // internal because this function is called within the contract
    //fucntion if the candidate is alreadu register or not.
    function candidateVerification(address _person) internal view returns (bool)  {
        for(uint i = 1; i < nextCandidateId; i++){
            if(CandidateDetails[i].candidateAddress == _person) {
                return false; //if candidate already exists
            }
        }
        return true; // if candidate does not exist
    }

    function candidateList()public view returns(Candidate[] memory) {
        Candidate[] memory candidatesArr = new Candidate[](nextCandidateId - 1);// new dynamic array with nextcandidateID. -1 length

        for(uint i = 1; i < nextCandidateId; i++) {
            candidatesArr[i - 1] = CandidateDetails[i];//added [i] at the end
        }
        return candidatesArr;
    }

//function related to voters 
    function voterRegister(
        string calldata _name,
        uint _age,
        string calldata _gender
    ) external {
        require(voterVerification(msg.sender) == true, "voter already registered");
        require(_age >= 18, "under 18, ineligble to vote");
        // require(voterId <= 100, "voter is full"); // implement this require if we want to limit the number of voters
        voterDetails[nextVoterId] = Voter(_name, _age, nextVoterId, _gender, 0, msg.sender);
        nextVoterId++;
    }

    function voterVerification(address _person) internal view returns(bool) {
        for(uint i = 1; i < nextVoterId; i++) {
            if(voterDetails[i].voterAddress == _person) {
                return false;
            }
        }
        return true;
    }

    function voterList() public view returns(Voter[] memory) {
        Voter[] memory voterArr = new Voter[](nextVoterId - 1);
        for(uint i = 1; i < nextVoterId; i++) {
            voterArr[i - 1] = voterDetails[i];
        }
        return voterArr;
    }

    function vote(uint _voterId, uint _id) external isVotingOver {//isvotingOver is a modifier
        //need voter id
        //need to check if voter has already voted T/F
        //store where voter voted
        require(voterDetails[_voterId].voteCandidateId == 0, "already voted"); //0 might throw error, so try 1
        require(voterDetails[_voterId].voterAddress == msg.sender, "you are not a voter");
        require(startTime !=0, "Voting not started");
        require(nextCandidateId == 3, "candidate registration yet"); //3 because in candidate verification we have a limit of 2 candidates
        require(_id > 0 && _id < 3, "invalid candidte Id");
        voterDetails[_voterId].voteCandidateId = _id;
        CandidateDetails[_id].votes++;

    }

    //misc functions

    function voteTime(uint _startTime, uint _endTime) external onlyCommisioner {//only eection commision (person who will deploy the contract) can call this function
        startTime = block.timestamp + _startTime; // e.g. voting start time is 6 pm. blocktime is 4pm, then we have to add 2 hours 
        endTime = startTime + _endTime;
        stopVoting = false;
    }

    function votingStatus() public view returns (string memory)  {
        if(startTime == 0) {
            return "voting has not started";
        } else if((startTime != 0 && endTime > block.timestamp) && stopVoting == false){
            return "in progress";
        } else {
            return "ended";
        }
    }


     function checkStatus() internal view returns(bool)  {
        string memory status = votingStatus();
        bytes32 hexa = keccak256(abi.encodePacked(status));
        // bytes32 started = keccak256(abi.encodePacked("voting has not started"));
        // bytes32 progress = keccak256(abi.encodePacked("in progress"));
        bytes32 ended = keccak256(abi.encodePacked("ended"));

        if(hexa == ended) {
            return true;
        } else {
            return false;
        }
    }

/*
       function result() external onlyCommisioner isVotingOver {
        Candidate storage candidate1 = CandidateDetails[1]; //candidate is a variable of type Candidate struct. candidateDetails is mapping
        Candidate storage candidate2 = CandidateDetails[2];
        
        if(candidate1.votes > candidate2.votes) { //.vote is a property in Candidate struct
            winner = candidate1.candidateAddress;
        } else {
            winner = candidate2.candidateAddress;
        }
    }
*/  


    //write a code for the condition in which there are more than 2 candidates

      function result() external onlyCommisioner {
        require(nextCandidateId > 1, "no candidate registered");
        uint maximumVotes = 0;
        address currentWinner;

        for ( uint i = 1; i <= nextCandidateId; i++) {

        if(CandidateDetails[i].votes > maximumVotes) { //.vote is a property in Candidate struct
            maximumVotes = CandidateDetails[i].votes;
            currentWinner = CandidateDetails[i].candidateAddress;
            }
        }
        winner = currentWinner; 
    }


    function emergency() public onlyCommisioner {
        stopVoting = true;
    }

   
  
}