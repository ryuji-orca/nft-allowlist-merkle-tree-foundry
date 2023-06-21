# NFT Allowlist Smart contract Foundry shachilog

## About thiis

This code was used in [shachilog's]() [definitive] How to implement NFT's arrow list (white list) with smart contracts.

## Features

- Foundry
- Contract using ERC721A
- Allowlist using merkle tree
- Free and payable NFT mint

## Useage

Read document [Installation](https://book.getfoundry.sh/getting-started/installation)

### Testing

```
forge test
```

### Deploy

Read document [Solidity Scripting](https://book.getfoundry.sh/tutorials/solidity-scripting?highlight=deploy#solidity-scripting)

#### Local

1.Start anvil

```
anvil
```

2.Copy private key to update $PRIVATE_KEY

```
forge script script/NftFree.s.sol:NftFreeScript --fork-url http://localhost:8545 --broadcast --private-key $PRIVATE_KEY
```

#### TestNet

```
forge script script/NftFree.s.sol:NftFreeScript --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv --private-key $PRIVATE_KEY
```

## License

Licensed under the [MIT license](https://github.com/ryuji-orca/nft-allowlist-merkle-tree-foundry/LICENSE.md).
