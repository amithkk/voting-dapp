//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

contract Voting {
    struct voter {
        address voterAddress; // The address of the voter
        uint256 tokensBought; // The total no. of tokens this voter owns
        uint256[] tokensUsedPerCandidate; // Array to keep track of votes per candidate.
    }

    address public owner;

    mapping(address => voter) public voterInfo;
    mapping(bytes32 => uint256) public votesReceived;

    bytes32[] public candidateList;
    address[] public voterAddresses;

    uint256 public totalTokens; // Total no. of tokens available for this election
    uint256 public balanceTokens; // Total no. of tokens still available for purchase
    uint256 public tokenPrice; // Price per token

   

 
   
    constructor(
        uint256 tokens,
        uint256 pricePerToken,
        bytes32[] memory candidateNames
    ) {
        candidateList = candidateNames;
        totalTokens = tokens;
        balanceTokens = tokens;
        tokenPrice = pricePerToken;
        owner = msg.sender;

        // maximum number of unique voters will be equal to the total number of tokens purchasable
        voterAddresses = new address[](totalTokens);
    }

    function totalVotesFor(bytes32 candidate) public view returns (uint256) {
        return votesReceived[candidate];
    }
 
    function voteForCandidate(bytes32 candidate, uint256 votesInTokens) public {
        uint256 index = indexOfCandidate(candidate);
        require(index != type(uint256).max);

        if (voterInfo[msg.sender].tokensUsedPerCandidate.length == 0) {
            for (uint256 i = 0; i < candidateList.length; i++) {
                voterInfo[msg.sender].tokensUsedPerCandidate.push(0);
            }
        }
        uint256 availableTokens = voterInfo[msg.sender].tokensBought -
            totalTokensUsed(voterInfo[msg.sender].tokensUsedPerCandidate);
        require(availableTokens >= votesInTokens);
        
        // iterate through the voterAddresses array and check if we ever encountered the voter before. note that this is time intensive and may cost gas
        for(uint256 i = 0; i < voterAddresses.length;i++){
            if (voterAddresses[i] == msg.sender)
            break;
            if (voterAddresses[i] == address(0)){
            voterAddresses[i] = msg.sender;    
            break;    
            }
        }

        
        votesReceived[candidate] += votesInTokens;
        voterInfo[msg.sender].tokensUsedPerCandidate[index] += votesInTokens;
    }

    function totalTokensUsed(uint256[] memory _tokensUsedPerCandidate)
        private
        pure
        returns (uint256)
    {
        uint256 totalUsedTokens = 0;
        for (uint256 i = 0; i < _tokensUsedPerCandidate.length; i++) {
            totalUsedTokens += _tokensUsedPerCandidate[i];
        }
        return totalUsedTokens;
    }

    function indexOfCandidate(bytes32 candidate) public view returns (uint256) {
        for (uint256 i = 0; i < candidateList.length; i++) {
            if (candidateList[i] == candidate) {
                return i;
            }
        }
        return type(uint256).max;
    }

    function buy() public payable returns (uint256) {
        uint256 tokensToBuy = msg.value / tokenPrice;
        require(tokensToBuy <= balanceTokens);
        voterInfo[msg.sender].voterAddress = msg.sender;
        voterInfo[msg.sender].tokensBought += tokensToBuy;
        balanceTokens -= tokensToBuy;
        return tokensToBuy;
    }

    function tokensSold() public view returns (uint256) {
        return totalTokens - balanceTokens;
    }

    function voterDetails(address user)
        public
        view
        returns (uint256, uint256[] memory)
    {
        return (
            voterInfo[user].tokensBought,
            voterInfo[user].tokensUsedPerCandidate
        );
    }

    function myTokenCount() public view returns (uint256) {
        return
            voterInfo[msg.sender].tokensBought -
            totalTokensUsed(voterInfo[msg.sender].tokensUsedPerCandidate);
    }

    function transferTo(address account) public {
        require(msg.sender == owner);
        payable(account).transfer(address(this).balance);
    }
     

    function allCandidates() public view returns (bytes32[] memory) {
        return candidateList;
    }
        

    // this function should return the currently present voter addresses.
    function showAllVotersAddresses() public view returns (address[] memory) {
        return voterAddresses;
    }
}
