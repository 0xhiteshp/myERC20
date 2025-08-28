-include .env

.PHONY: all test clean remove install update build snapshot format anvil deploy deploy-sepolia verify help

DEFAULT_ANVIL_KEY := 0xdbda1821b80551c9d65939329250298aa3472ba22feea921c0cf5d620ea67b97

all: clean install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

# Install common deps (forge-std and OpenZeppelin already present via remappings)
install :; forge install foundry-rs/forge-std@v1.8.2 --no-commit && forge install openzeppelin/openzeppelin-contracts@v5.0.2 --no-commit

# Update Dependencies
update:; forge update

build:; forge build

test :; forge test -vv

snapshot :; forge snapshot

format :; forge fmt

# Start local anvil with a deterministic mnemonic
anvil :; anvil -m 'test test test test test test test test test test test test junk' --steps-tracing --block-time 1

# Deploy to local anvil using the default anvil key
deploy:
	@forge script script/Deploy.s.sol:Deploy \
		--rpc-url http://127.0.0.1:8545 \
		--private-key $(DEFAULT_ANVIL_KEY) \
		--broadcast -vvvv

# Deploy to Sepolia using PRIVATE_KEY from .env
# Requires: SEPOLIA_RPC_URL and PRIVATE_KEY in your environment
deploy-sepolia:
	@forge script script/Deploy.s.sol:Deploy \
		--rpc-url $(SEPOLIA_RPC_URL) \
		--private-key $(PRIVATE_KEY) \
		--broadcast -vvvv

# Example verification target (adjust chain-id, address, and compiler if needed)
# Requires: ETHERSCAN_API_KEY
verify:
	@echo "Adjust address and compiler version before running verify"
	@forge verify-contract \
		--chain-id 11155111 \
		--num-of-optimizations 200 \
		--watch \
		--etherscan-api-key $(ETHERSCAN_API_KEY) \
		--compiler-version v0.8.27+commit.40a35a09 \
		<DEPLOYED_ADDRESS> src/MyToken.sol:myERC

help:
	@echo "Common targets:"
	@echo "  make anvil                # start local node"
	@echo "  make deploy               # deploy to anvil"
	@echo "  make deploy-sepolia       # deploy to Sepolia (uses env vars)"
	@echo "  make test | build | clean | format | snapshot"
