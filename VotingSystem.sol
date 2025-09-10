/**
 * @title THE FUTURE VOTE SMART CONTRACT
 * @dev This smart contract manages the voting functionality for the Future Vote system.
 * @author GOODNESS E. (COAT)
 * @notice This contract is owned by Havlilah Blockchain Studios, Inc.
 * @dev Created on 15th of May, 2024.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/* IMPORT STATEMENTS */
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol"; // Importing ERC721 contract for token functionality
import "@openzeppelin/contracts/access/Ownable.sol"; // Importing Ownable contract for access control
import "@openzeppelin/contracts/utils/Counters.sol"; // Importing Counters library for managing token IDs

/**
 * @title IDENTIFICATION SYSTEM CONTRACT
 * @dev This contract manages the identification system for the Future Vote system.
 */
contract DID is ERC721URIStorage, Ownable {
    /* VARIABLE DECLARATION */
    using Counters for Counters.Counter; // Using Counters library for managing token IDs
    Counters.Counter private tokenIds; // Counter for generating unique token IDs

    /**
     * @dev Constructor function to initialize the ERC721 token with the name and symbol.
     */
    constructor() ERC721("FUTUREVOTEDID", "FVD") {}

    /**
     * @dev Mint function to create a new token with the specified token URI.
     * @param _tokenURI The URI for the token metadata.
     * @param minter The address of the account minting the token.
     * @return The ID of the newly created token.
     */
    function mint(string memory _tokenURI, address minter)
        public
        onlyOwner
        returns (uint256)
    {
        tokenIds.increment(); // Increment the token ID counter for the next token
        uint256 newDidId = tokenIds.current(); // Get the current token ID
        _mint(minter, newDidId); // Mint a new token with the specified owner and ID
        _setTokenURI(newDidId, _tokenURI); // Set the token URI for the newly minted token
        return newDidId; // Return the ID of the newly created token
    }
}

/**
 * @title FUTURE VOTE CONTRACT
 * @dev This contract manages the voting functionality for the Future Vote system.
 */
contract FutureVote is Ownable {

    /** Constants **/
    DID immutable voterDid;
    using Counters for Counters.Counter; // Using Counters library for managing elections IDs
    Counters.Counter private eId; // Counter for generating unique election IDs

    struct election {
        address admin;
        string name;
        uint256 id;
        address[] candidates;
        bool started;
    }

    /** VARIABLES **/
    mapping(address => uint) public voters; //holds voters data
    mapping(uint256 => election) public electionData; //holds election data
    mapping(uint256 => mapping(address => uint)) public candidateVotes; //candiate voting information;
    mapping(uint256 => mapping(address => bool)) public votersVotes; //voters voting information;
    
    /* EVENTS */
    event newElection(uint256 electionId, address admin); 
    event newCandidate(uint256 electionId, address candidate); 
    event newVoter(address voter); 
    event newVote(uint256 electionId, address candiate, address voter);
    event newAdmin(uint256 electionId, address admin);
    event ended(uint256 electionId);
    
    constructor() {
        voterDid = new DID();
    }   

    /** FUNCTIONS **/

    /* MODIFIERS */
    
    // Modifier to check if the candidate is registered
    modifier onlyRegisteredCandidate(address candidate) {
        require(voters[candidate] > 0, "Please register this user first");
        _;
    }

    // Modifier to check if this the admin of the election
    modifier onlyAdmin(uint256 electionId) {
        require(electionData[electionId].admin == msg.sender, "Not the admin of this election");
        _;
    }
    /*** END MODIFIER **/


    /** To register a new voter **/
    function registerVoter(string memory voterUri) external returns (bool) {
        //mint new DID for a voter
        voters[msg.sender] = voterDid.mint(voterUri, msg.sender);
        emit newVoter(msg.sender);
        return true;
    }

    /** To start a new voting session **/
    function startElection(string memory name) external returns (uint256) {
        eId.increment();
        address[] memory candidates;
        electionData[eId.current()] = election(
            msg.sender,
            name,
            eId.current(),
            candidates,
            true
        );
        emit newElection(eId.current(), msg.sender);
        return eId.current();
    }

    /** to register participant **/
    function registerCandidate(address candidate, uint256 electionId) 
    external onlyRegisteredCandidate(candidate) 
    onlyAdmin(electionId) returns (bool) {
        require(!checkCandidateExists(candidate, electionId), "Already registered");
        //register the candidate
        electionData[electionId].candidates.push(candidate);
        emit newCandidate(electionId, candidate);
        return true;
    }

    /** to vote **/
    function vote(address candidate, uint256 electionId) 
    external 
    onlyRegisteredCandidate(candidate) 
    returns (bool) {
        require(electionData[electionId].started, "Eelction has ended"); //check if the election is still ongoing
        require(!votersVotes[electionId][msg.sender], "Has voted"); //check if voter has voted
        //increment candiate votes
        candidateVotes[electionId][candidate]++;
        votersVotes[electionId][msg.sender] = true;
        emit newVote(electionId, candidate, msg.sender);
        return true;
    }

    /** to end an election */
    function end(uint256 electionId) 
    external 
    onlyAdmin(electionId) 
    returns (bool) {
        electionData[electionId].started = false;
        emit ended(electionId);
        return true;
    }

    /** to transfer admin ownership of election */
    function changeElectionAdmin(uint256 electionId, address admin) 
    external 
    onlyAdmin(electionId) 
    returns (bool) {
        electionData[electionId].admin = admin;
        emit newAdmin(electionId, admin);
        return true;
    }

    /* GETTERS */

    /** To return list of candidates **/
    function electionCandidates(uint256 electionId) external view returns(address [] memory) {
        return electionData[electionId].candidates;
    }

    /* UTILS */

    //check if candidate exists
    function checkCandidateExists(address candidate, uint256 id) public view returns (bool) {
        for (uint256 i = 0; i < electionData[id].candidates.length; i++) {
            if (electionData[id].candidates[i] == candidate) {
                return true;
            }
        }
        return false;
    } 
 }
