# Decentralized Time Banking System

A blockchain-based platform that enables community members to exchange services using time as currency. This system facilitates peer-to-peer service exchange while ensuring transparent tracking of time credits and democratic governance of the platform.

## System Overview

The Decentralized Time Banking System consists of four main smart contracts that work together to create a trustless, community-driven service exchange platform:

### Skill Registry Contract
- Maintains a comprehensive database of user skills and availability
- Allows users to register their expertise and update their availability
- Implements skill verification and endorsement mechanisms
- Supports searching and filtering of service providers by skill type

### Time Credit Contract
- Manages the creation and transfer of time-based tokens
- Tracks earned and spent time credits for each user
- Implements time credit expiration rules
- Provides transaction history and balance checking functionality

### Service Exchange Contract
- Facilitates matching between service providers and receivers
- Handles service request creation and acceptance
- Manages service completion verification
- Automates time credit transfers upon service completion
- Implements dispute resolution mechanisms

### Community Governance Contract
- Enables community voting on system parameters and rules
- Manages proposal creation and voting processes
- Implements vote counting and result execution
- Controls system upgrades and modifications

## Getting Started

### Prerequisites
- Node.js v16.0 or higher
- Hardhat
- MetaMask or similar Web3 wallet
- IPFS (for decentralized storage)

### Installation
1. Clone the repository:
```bash
git clone https://github.com/your-username/decentralized-timebanking.git
cd decentralized-timebanking
```

2. Install dependencies:
```bash
npm install
```

3. Configure environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. Compile contracts:
```bash
npx hardhat compile
```

5. Deploy contracts:
```bash
npx hardhat run scripts/deploy.js --network <your-network>
```

## Usage

### For Service Providers
1. Register your skills and availability through the Skill Registry Contract
2. Monitor incoming service requests
3. Accept requests and provide services
4. Receive time credits upon service completion

### For Service Receivers
1. Search for service providers based on required skills
2. Create service requests with time credit offers
3. Confirm service completion
4. Transfer time credits automatically upon confirmation

### For Community Members
1. Participate in governance by creating or voting on proposals
2. Monitor system metrics and community health
3. Contribute to skill verification and user reputation

## Smart Contract Architecture

### Skill Registry Contract
```solidity
interface ISkillRegistry {
    function registerSkill(string memory skill, uint8 expertiseLevel);
    function updateAvailability(bool isAvailable);
    function endorseSkill(address user, string memory skill);
    function searchProviders(string memory skill) returns (address[] memory);
}
```

### Time Credit Contract
```solidity
interface ITimeCredit {
    function transferCredits(address to, uint256 amount);
    function checkBalance(address user) returns (uint256);
    function getTransactionHistory(address user) returns (Transaction[] memory);
}
```

### Service Exchange Contract
```solidity
interface IServiceExchange {
    function createRequest(string memory skill, uint256 timeCredits);
    function acceptRequest(uint256 requestId);
    function confirmCompletion(uint256 requestId);
    function initiateDispute(uint256 requestId);
}
```

### Community Governance Contract
```solidity
interface ICommunityGovernance {
    function createProposal(string memory description, bytes memory data);
    function castVote(uint256 proposalId, bool support);
    function executeProposal(uint256 proposalId);
}
```

## Contributing

We welcome contributions from the community. Please follow these steps:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to your branch
5. Create a Pull Request

Please ensure your code follows our style guidelines and includes appropriate tests.

## Security

- All smart contracts have been audited by [Audit Firm Name]
- Time credits are non-transferable outside the platform
- Multi-signature requirements for system upgrades
- Rate limiting to prevent spam
- Dispute resolution mechanism with community arbitration

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Contact

For questions and support:
- Discord: [Link]
- Twitter: [@timebanking]
- Email: support@timebanking.eth

## Acknowledgments

- OpenZeppelin for secure smart contract implementations
- [Other contributors and inspiration sources]
