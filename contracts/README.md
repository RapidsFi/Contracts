# Subscription Contract Details
## Introduction

The Subscription Contract is an innovative piece of technology that powers a subscription-like model on the blockchain. It allows users to "subscribe" to a service by committing to periodic payments in a specific token.

The unique aspect of the Subscription Contract is that it's permission-based. Users need to give their explicit permission through a digital signature before any tokens can be deducted from their account.

This model offers users complete control over their funds and aligns with the blockchain principles of transparency and autonomy.

## How it Works

1. **User Interaction**: A user interacts with the Subscription Contract through a frontend interface, which displays all necessary information about the subscription, such as the token to be used, the amount, and the billing period.
2. **Signature Requirement**: To initialize a subscription, the user must provide their digital signature. This signature is a confirmation that the user agrees to the terms of the subscription.
3. **Billing Cycle**: The Subscription Contract cannot charge users arbitrarily. It can only process the transaction after the end of the specified billing period.
4. **Security**: The Subscription Contract abides by strict security protocols. All transactions are secured by the Ethereum network, and user signatures are required for each billing cycle.

## Control Over Token Allowances
Even after subscribing, users retain full control over their token allowances. This means they can decide to increase or decrease their allowance and terminate their subscription at any time.

A useful tool for managing token allowances is [revoke.cash](https://revoke.cash/). This service allows you to review and adjust the allowances you've set for various decentralized applications (DApps).

## Contract Deployment
For those interested in the technical specifics of the Subscription Contract or those who wish to inspect the contract for security reasons, you can view the deployed contract here:
- Sepolia: [0x13c0B00a0beF323940Fd7008925F39020bB85dC4](https://sepolia.etherscan.io/address/0x13c0b00a0bef323940fd7008925f39020bb85dc4)

Please note that interacting directly with the contract should only be done by experienced users. Always ensure you understand the implications of any transactions you're signing on the blockchain.

For more information or questions about the Subscription Contract, feel free to reach out to team@rapids.finance or open an issue in this repository.
