# Energy Credit Market Smart Contract

## 📋 Overview

**EnergyCreditMarket.clar** is a Stacks blockchain smart contract that enables the creation, trading, and retirement of energy credits as non-fungible tokens (NFTs). This contract provides a decentralized marketplace for renewable energy projects to issue and trade verified energy credits on the Stacks network.

## ✨ Features

- **Project Registration**: Energy projects can register with metadata, capacity limits, and verification status
- **Producer Management**: Admin-controlled approval system for authorized credit producers
- **NFT Minting**: Mint individual or batch energy credits as non-fungible tokens
- **Marketplace**: List credits for sale, cancel listings, and purchase credits with STX
- **Credit Retirement**: Token owners can permanently retire credits to offset carbon emissions
- **Admin Controls**: Treasury management and STX withdrawal capabilities
- **Error Handling**: Comprehensive error constants for proper transaction validation

## 🚀 Quick Start

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks CLI tools
- Node.js 16+

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd EnergyCreditMarket

# Install dependencies
clarinet install

# Run contract checks
clarinet check

# Run tests
clarinet test
```

## 📦 Contract Functions

### Admin Functions
- `set-treasury(who: principal)` - Update treasury address
- `approve-producer(project-id: uint, who: principal, approve: bool)` - Approve/reject producers
- `withdraw(to: principal, amount: uint)` - Withdraw STX
- `withdraw-all-to-treasury()` - Withdraw all contract balance to treasury

### Project Management
- `register-project(metadata: buff 64, cap: uint, verified: bool)` - Register new energy project
- `get-project(id: uint)` - Retrieve project details

### Minting
- `mint-one-credit(project-id: uint)` - Mint a single energy credit
- `mint-credits(project-id: uint, quantity: uint, uri: string-ascii 64)` - Mint multiple credits

### Marketplace
- `list-for-sale(token-id: uint, price: uint)` - List credit for sale
- `cancel-listing(token-id: uint)` - Cancel active listing
- `buy-credit(token-id: uint)` - Purchase listed credit
- `get-listing(token-id: uint)` - Retrieve listing details

### Retirement
- `retire-credit(token-id: uint)` - Permanently retire a credit
- `get-token-info(id: uint)` - Check token status and retirement

### Query Functions
- `is-producer-approved(project-id: uint, who: principal)` - Check producer approval
- `get-treasury()` - Get current treasury address
- `get-admin()` - Get current admin address

## 🏗️ Data Structures

### Projects Map
```clarity
{
  id: uint,
  owner: principal,
  metadata: buff 64,
  cap: uint,
  minted: uint,
  verified: bool
}
```

### Producers Map
```clarity
{
  project-id: uint,
  who: principal,
  approved: bool
}
```

### Token Info Map
```clarity
{
  token-id: uint,
  project-id: uint,
  retired: bool
}
```

### Listings Map
```clarity
{
  token-id: uint,
  seller: principal,
  price: uint
}
```

## 🔐 Security Features

- **Admin-Only Functions**: Critical operations protected by admin checks
- **Authorization Checks**: Verify ownership and producer approval before operations
- **Input Validation**: Comprehensive assertions for all inputs
- **Error Handling**: Specific error codes for debugging and user feedback
- **NFT Ownership Verification**: Validate token ownership before transactions

## 📊 Error Codes

| Code | Error | Description |
|------|-------|-------------|
| 100 | `err-not-admin` | Only admin can perform this action |
| 101 | `err-not-found` | Project or token not found |
| 102 | `err-not-authorized` | User not authorized for this operation |
| 103 | `err-invalid-args` | Invalid function arguments |
| 104 | `err-mint-failed` | NFT minting failed |
| 105 | `err-already-listed` | Token already listed for sale |
| 106 | `err-not-listed` | Token not currently listed |
| 107 | `err-transfer-failed` | STX transfer failed |

## 🧪 Testing

```bash
# Run all tests
clarinet test

# Run specific test file
clarinet test tests/energy-credit-market_test.ts

# Run contract checks
clarinet check

# Check for warnings
clarinet check --warnings
```

## 📝 Usage Example

```clarity
;; 1. Register a new renewable energy project
(register-project 0x "metadata_hash" u1000 true)
;; Response: (ok u1)

;; 2. Approve a producer
(approve-producer u1 'SP1234567890 true)
;; Response: (ok true)

;; 3. Mint energy credits
(mint-one-credit u1)
;; Response: (ok u1)

;; 4. List credit for sale
(list-for-sale u1 u5000000)
;; Response: (ok true)

;; 5. Buy the credit
(buy-credit u1)
;; Response: (ok true)

;; 6. Retire the credit
(retire-credit u1)
;; Response: (ok true)
```

## 🔄 Workflow

```
1. Project Owner registers energy project
   ↓
2. Admin approves producer for the project
   ↓
3. Producer mints energy credits (NFTs)
   ↓
4. Seller lists credits on marketplace
   ↓
5. Buyer purchases credits with STX
   ↓
6. Token owner retires credit (carbon offset)
```

## 🛠️ Development

### File Structure
```
EnergyCreditMarket/
├── contracts/
│   └── EnergyCreditMarket.clar
├── tests/
│   └── energy-credit-market_test.ts
├── Clarinet.toml
└── README.md
```

### Building
```bash
# Compile contract
clarinet check

# Deploy to testnet
clarinet contract deploy
```

## 🤝 Contributing

Contributions are welcome! Please submit pull requests or open issues for bugs and feature requests.

## 📧 Support

For questions or support, please open an issue on the GitHub repository.

## 🔗 Related Resources

- [Stacks Documentation](https://docs.stacks.co)
- [Clarity Language Guide](https://docs.stacks.co/clarity)
- [Clarinet CLI](https://github.com/hirosystems/clarinet)

---

**Status**: ✅ Production Ready (v1.0)
**Last Updated**: November 22, 2025
