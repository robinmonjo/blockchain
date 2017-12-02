# Coincoin.Token

Proof-of-concept of a cryptocurrency implemented on top of the [`blockchain` app](../coincoin_blockchain/README.md). The goal is to keep it as simple as possible but complete enough to understand how most cryptocurrencies such as Bitcoin or Ethereum work.

## Usage

Setup a blockchain as explained in the [main readme](../../README.md#setup)

On startup, each node generates a wallet (a private/public key pair and an address derived from the public key):

```elixir
$node1> Coincoin.Token.address()
"20902B4FF51658B9CA7C3604F8A5F7F40B9B156C" # node1 address
```

Each node starts with 0 token (nothing surprising here, the only block in the blockchain is the genesis block, there is no transaction):

```elixir
$node1> Coincoin.Token.balance()
0
````

To "inject" tokens in the system we need to cheat and use a *forbidden* API:

```elixir
$node1> Coincoin.Token.free_tokens(20) # this will give node1 20 tokens
[...]
$node1> Coincoin.Token.balance()
20
```

The `free_tokens/1` function writes a particular transaction into the blockchain, that gives tokens to the calling node.

Now that tokens are in the system, we can start exchanging it between the nodes of our network using the `send/2` API:

```elixir
# get back the address of node3
$node3> Coincoin.Token.address()
"9F90526460468618E54B49CC11E7473778BE7288"

# from node1 make a transaction of 10 tokens to node3
$node1> Coincoin.Token.send(10, "9F90526460468618E54B49CC11E7473778BE7288")
[...]

# check new balances
$node1> Coincoin.Token.balance()
10

$node3> Coincoin.Token.balance()
10
```

In this implementation, a block (of the blockchain) only contains **one** transaction (which is not the case in a real life implementation). You can use the `Coincoin.Blockchain.blocks/0` API to see the blocks that get mined into the blockchain.

## Internals

### Wallet

A wallet contains 3 fields, [ECDH](https://en.wikipedia.org/wiki/Elliptic-curve_Diffie%E2%80%93Hellman) keys (`public_key` and `private_key`) and `address`. The address is a [public key hash](https://en.bitcoin.it/wiki/Technical_background_of_version_1_Bitcoin_addresses) without the base56 encoding.

### Transaction

A transaction contains a list of inputs (an input points to a transaction output), a list of outputs (recipients of the transaction and the amount of tokens), a public key (public key of the sender), a signature (computed from the sender private key) and a hash.

To be validated and added to the blockchain transactions must be verified. Checkout the `Coincoin.Token.Transaction.Verify.verify_transaction/2` function to see what happens.

### Ledger

Cryptocurrencies and blockchains are different concepts eventough they often get confused. In this implementation, the `Ledger` module abstracts the blockchain so it is seen as a simple list of transactions while still relying on blockchain immutability properties.
