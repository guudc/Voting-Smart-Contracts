# Voting System Smart Contracts

This repository contains two separate voting-related smart contracts:

1. **Basic Voting Contract** – A simple voting system for aspirants.
2. **Future Vote System** – An advanced voting platform integrated with decentralized identities (DID) and role-based election management.

Both contracts are written in Solidity and serve different purposes depending on the use case.

---

## 1. Basic Voting Contract

### Overview

This contract provides a **minimal voting mechanism** where voters can cast one vote for a list of aspirants. Aspirants are predefined in the constructor, and each vote is permanently recorded.

### Features

* Register aspirants (added at contract deployment).
* Track votes per aspirant.
* Prevent double voting from the same address.

### Contract Details

```solidity
pragma solidity ^0.6.6;

contract Voting {
    struct Aspirant {
        uint id;
        string name;
        uint voteCount;
    }

    mapping(uint => Aspirant) public aspirants;
    uint public aspirantcount;
    mapping(address => bool) public voter;

    constructor() public {
        addAspirant("Dave");
        addAspirant("Lucy");
    }

    function addAspirant(string memory _name) private {
        aspirantcount++;
        aspirants[aspirantcount] = Aspirant(aspirantcount, _name, 0);
    }

    function vote(uint _aspirantid) public {
        require(!voter[msg.sender], "Already voted");
        voter[msg.sender] = true;
        aspirants[_aspirantid].voteCount++;
    }
}
```

### Usage

1. Deploy the contract.
2. Default aspirants: **Dave** and **Lucy**.
3. Call `vote(uint _aspirantid)` to cast a vote.

   * Each address can only vote once.
   * Votes are tracked in `aspirants[_id].voteCount`.

---

## 2. Future Vote System (with DID)

### Overview

The **Future Vote System** is an advanced, modular voting platform built by **Havilah Blockchain Studios, Inc.**.
It integrates:

* **Decentralized Identity (DID)** using ERC721 tokens.
* **Election management** with admin privileges.
* **Candidate registration** restricted to registered voters.
* **On-chain voting and results tracking**.

### Contracts

There are **two contracts**:

#### 🔹 DID Contract

Manages voter identities as ERC721 tokens.

* Each registered voter gets a unique DID NFT.
* Only the contract owner can mint identities.

#### 🔹 FutureVote Contract

Handles elections and voting.

* Start/end elections.
* Register candidates.
* Allow verified voters to vote once per election.
* Transfer election admin role.

---

### Key Features

* **Decentralized Voter Registration** – Each voter receives a DID NFT.
* **Election Creation** – Any address can start a new election.
* **Candidate Management** – Only registered voters can become candidates.
* **One Person, One Vote** – Prevents multiple votes from the same address.
* **Role-Based Administration** – Election admins can manage candidates, votes, and transfer control.
* **Events** for elections, candidates, votes, and results.

---

### Contract Snippets

#### Register Voter

```solidity
function registerVoter(string memory voterUri) external returns (bool);
```

* Mints a new DID NFT for the caller.

#### Start Election

```solidity
function startElection(string memory name) external returns (uint256);
```

* Creates a new election and assigns the caller as admin.

#### Register Candidate

```solidity
function registerCandidate(address candidate, uint256 electionId) external onlyAdmin(electionId);
```

* Admin registers a candidate if they are a valid DID holder.

#### Vote

```solidity
function vote(address candidate, uint256 electionId) external returns (bool);
```

* Casts a vote for a candidate (only once per election).

#### End Election

```solidity
function end(uint256 electionId) external onlyAdmin(electionId);
```

* Ends the election.

---

### Example Workflow

1. **Register voters** → Each voter gets a DID NFT.
2. **Start an election** → Admin creates a new election.
3. **Register candidates** → Only DID holders can be candidates.
4. **Voting** → Voters cast votes for candidates.
5. **End election** → Admin closes voting and results are final.

---

## ⚠️ Security Notes

* The **Basic Voting Contract** has no advanced security (suitable for demos/learning).
* The **Future Vote Contract** is more robust but **lacks vote secrecy** (votes are public on-chain).
* Consider adding:

  * Access control (e.g., onlyOwner for certain functions).
  * Cryptographic proof systems (e.g., zk-SNARKs) for private voting.
  * Election result verification mechanisms.

---

## 📝 License

Both contracts are licensed under the [MIT License](LICENSE).

---
 
