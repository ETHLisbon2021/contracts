# Eligble

The Eligible smart contract allows to set up the tokensale, receive user's deposits and distirbute tokens based on the provided information.

![sheme](https://github.com/ETHLisbon2021/contracts/blob/main/img.png)

## Launching the sale

```js
Eligible.initSale(
    token, // address of the selling token
    totalCap, // total amount of funds
    distribution, // total tokens to distribute
    maxDeposit, // max deposit per user
    endingAt, // date of the ending of token sale
    ipfsHash // IPFS hash of the description file
);
```

example

```shell
npx hardhat run scripts/init.js
```

## Deposit funds

```js
Eligible.deposit(
    token, // address of the selling token
    receiver //the address which will checked and get the allocation
);
```

example

```shell
npx hardhat run scripts/deposit.js
```

## Token distribution

```js
Eligible.disctirbute(
    token, // address of the selling token
    receivers, // a Array of receivers receivers
    amounts //  a Array of receivers amounts
);
```

example

```shell
npx hardhat run scripts/distribute.js
```
