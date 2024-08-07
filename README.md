# GoerBridge-solidity

GoerBridge uses Solidity smart contracts to enable transfers to and from EVM compatible chains. These contracts consist of a core bridge contract (Bridge.sol) and a set of handler contracts (ERC20Handler.sol, ERC721Handler.sol, and GenericHandler.sol). The bridge contract is responsible for initiating, voting on, and executing proposed transfers. The handlers are used by the bridge contract to interact with other existing contracts.

Read more [here]().

## Requirements
requires:   `// SPDX-License-Identifier: MIT` and `compiler 0.8.18`.

# Deploy Essential Contracts
- Step 1: Deploy contract Bridge
- Step 2: Deploy contract Factory (Input: contract bridge deployed)
- Step 3: Use function deployedBridge to deploy Bridge to Factory (input contract origin is contract bridge at step 1)
- Step 4: Go to explorer, type transaction hash in step 3 and go to logs to see new contract bridge
- Step 5: Go to new contract bridge create blockchains and finish.

# Configuration
## Factory

### Deploy Fee

### Upgrade Bridge original contract

## Bridge

### Bridge fee

- FEE_NATIVE by native token
- Percentage Fee by token

### Change Monitor Address

### Change Owner

User only use function receive tokens to bridge token from blockchain A to blockchain B
