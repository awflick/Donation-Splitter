# Donation Splitter

This Solidity smart contract splits incoming Ether donations equally between a fixed set of payees. Any leftover remainder (or "dust") is forwarded to the contract owner. It includes a complete Foundry test suite with full coverage.

---

## 📜 Contract Overview

- **Contract Name:** `DonationSplitter`
- **Language:** Solidity `^0.8.25`
- **Purpose:** Accept ETH donations and split them equally among 3 fixed payees.
- **Features:**
  - Handles ETH sent via `receive()` and `fallback()` functions
  - Emits events for received donations and distribution
  - Owner-only `splitDonation()` function
  - Sends leftover dust to the owner
  - Fully tested with Foundry

---

## 🧪 Test Suite Summary

| Metric            | Coverage |
|-------------------|----------|
| ✅ Line Coverage   | 100%     |
| ✅ Function Coverage | 100%     |
| ✅ Branch Coverage | 81.82%   |
| ✅ Tests Passed    | 9/9      |

Test coverage includes:
- Initial state
- Donation splitting
- Fallback & receive function
- Invalid inputs & permission checks
- Dust handling logic

Run tests with:

```bash
forge test --coverage
```

---

## 🔧 How to Run Locally

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed:
  ```bash
  curl -L https://foundry.paradigm.xyz | bash
  foundryup
  ```

### Clone and Test

```bash
git clone https://github.com/YOUR_USERNAME/Donation-Splitter.git
cd Donation-Splitter
forge install
forge build
forge test --coverage
```

---

## 📁 Project Structure

```
Donation-Splitter/
├── src/
│   └── DonationSplitter.sol      # Main contract
├── test/
│   └── DonationSplitterTest.t.sol # Full test suite
├── lib/
│   └── forge-std/                 # Foundry standard library
├── foundry.toml                  # Foundry config
└── README.md                     # You're here
```

---

## 📦 Dependencies

- [`forge-std`](https://github.com/foundry-rs/forge-std) for testing utilities

---

## ✍️ Author

Project by [Adam Flick](https://github.com/awflick)  
Developed as a solo challenge project.

---

## 📄 License

[MIT](./LICENSE)

