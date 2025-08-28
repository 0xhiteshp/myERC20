# MyToken (myERC)

> Try it yourself (Sepolia)
>
> - Contract: `0xFfc5A2a66Ab379A803F23cCA61b313431f787d3F`
> - View on Etherscan: https://sepolia.etherscan.io/address/0xFfc5A2a66Ab379A803F23cCA61b313431f787d3F
> - Read/Write on Etherscan (Contract tab) after verification
> - Add to MetaMask: Add Token → Custom Token → Paste the contract address above (symbol `SJ`, decimals `18`)
>
> Cast quick checks:
> ```bash
> export RPC_URL="https://eth-sepolia.g.alchemy.com/v2/YOUR_KEY"
> export TOKEN="0xFfc5A2a66Ab379A803F23cCA61b313431f787d3F"
> cast call $TOKEN "name()(string)" --rpc-url $RPC_URL
> cast call $TOKEN "symbol()(string)" --rpc-url $RPC_URL
> cast call $TOKEN "decimals()(uint8)" --rpc-url $RPC_URL
> ```

A minimal ERC‑20 token built with Foundry + OpenZeppelin.

- Name: `myERC`
- Symbol: `SJ`
- Decimals: `18`
- Initial supply: `100,000` tokens minted at deploy time to the recipient (the deployer in our script)
- Ownership: `Ownable` — the `initialOwner` is set at deploy time (the deployer in our script)

## Tech Stack
- Solidity ^0.8.27
- Foundry (forge, cast, anvil)
- OpenZeppelin Contracts ^5.x

## Contracts
- `src/MyToken.sol` → `myERC`
  - constructor(address recipient, address initialOwner)
  - Mints 100,000 tokens to `recipient`
  - Sets `initialOwner` as Ownable owner

## Getting Started

### Prerequisites
- Install Foundry: `curl -L https://foundry.paradigm.xyz | bash` then `foundryup`
- Node provider account (e.g., Alchemy) for Sepolia, and a funded Metamask account for deploy

### Install
```bash
git clone <this-repo-url>
cd MyToken
forge install
forge build
```

## Local Development

### Start a local node
```bash
make anvil
```

### Deploy locally
```bash
# in another terminal
make deploy
```
This uses a deterministic Anvil private key and deploys to `http://127.0.0.1:8545`.

### Interact (examples)
```bash
export RPC_URL=http://127.0.0.1:8545
export TOKEN_ADDR=<DEPLOYED_ADDRESS>
cast call $TOKEN_ADDR "name()(string)" --rpc-url $RPC_URL
cast call $TOKEN_ADDR "symbol()(string)" --rpc-url $RPC_URL
cast call $TOKEN_ADDR "totalSupply()(uint256)" --rpc-url $RPC_URL | cast --to-dec
```

## Test & Coverage
```bash
make test
forge coverage
# Optional HTML report
yarn global add lcov || true
forge coverage --report lcov && genhtml -o coverage lcov.info
```

## Deploy to Sepolia

1) Create `.env` in project root:
```bash
SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/v2/YOUR_KEY
PRIVATE_KEY=0xYOUR_METAMASK_PRIVATE_KEY
ETHERSCAN_API_KEY=YOUR_ETHERSCAN_KEY   # optional
```

2) Load env and deploy:
```bash
set -a; source .env; set +a
make deploy-sepolia
# or
aforge script script/Deploy.s.sol:Deploy \
  --rpc-url "$SEPOLIA_RPC_URL" \
  --private-key "$PRIVATE_KEY" \
  --broadcast -vvvv
```

3) The deployed address will appear in the terminal and in:
`broadcast/Deploy.s.sol/11155111/run-latest.json`

## Verify on Etherscan (optional)
Constructor: `constructor(address recipient, address initialOwner)`.
If you used the deployer as both params (default script behavior):
```bash
ADDR=<DEPLOYED_ADDRESS>
DEPLOYER=$(cast wallet address --private-key "$PRIVATE_KEY")
forge verify-contract \
  --chain-id 11155111 \
  --etherscan-api-key "$ETHERSCAN_API_KEY" \
  "$ADDR" src/MyToken.sol:myERC \
  --constructor-args $(cast abi-encode "constructor(address,address)" "$DEPLOYER" "$DEPLOYER") \
  --watch
```

## Makefile Commands
```bash
make build            # forge build
make test             # forge test -vv
make format           # forge fmt
make anvil            # start local anvil
make deploy           # deploy to local anvil
make deploy-sepolia   # deploy to Sepolia using .env
```

## Project Layout
```
MyToken/
├─ src/
│  └─ MyToken.sol           # ERC-20 token (myERC)
├─ script/
│  └─ Deploy.s.sol          # Foundry deploy script (uses PRIVATE_KEY)
├─ test/
│  ├─ MyToken.t.sol         # Token behavior tests
│  └─ DeployScript.t.sol    # Script deployment test
├─ broadcast/                # Deployment artifacts (auto-generated)
├─ Makefile                  # Convenience commands
├─ foundry.toml
└─ README.md
```

## Notes
- Keep your `.env` private. Do not commit it.
- Ensure your Sepolia account has enough ETH for gas.
- This repo uses SPDX identifiers and OpenZeppelin for security best practices.

---

