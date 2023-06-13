// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Subscription is EIP712, Ownable {
    using ECDSA for bytes32;
    using SafeMath for uint256;

    mapping(bytes32 => uint256) public nextValidTimestamp;

    event ExecuteSubscription(
        address indexed from,
        address indexed to,
        address tokenAddress,
        uint256 tokenAmount,
        uint256 periodSeconds,
        uint256 nonce
    );

    event CancelSubscription(
        address indexed from,
        address indexed to,
        address tokenAddress,
        uint256 tokenAmount,
        uint256 periodSeconds,
        uint256 nonce
    );

    uint256 public gracePeriodSeconds = 300;

    constructor() EIP712("Subscription", "1") {}

    function isSubscriptionActive(
        bytes32 subscriptionHash
    )
        public
        view
        returns (bool)
    {
        if(nextValidTimestamp[subscriptionHash] == type(uint256).max) {
            return false;
        }
        return (block.timestamp.add(gracePeriodSeconds) >= nextValidTimestamp[subscriptionHash]);
    }

    function getSubscriptionHash(
        address from,
        address toAddress,
        address tokenAddress,
        uint256 tokenAmount,
        uint256 periodSeconds,
        uint256 nonce
    )
        public
        view
        returns (bytes32)
    {
        return _hashTypedDataV4(keccak256(abi.encode(
            keccak256("Subscription(address from,address toAddress,address tokenAddress,uint256 tokenAmount,uint256 periodSeconds,uint256 nonce)"),
            from,
            toAddress,
            tokenAddress,
            tokenAmount,
            periodSeconds,
            nonce
        )));
    }

    function getSubscriptionSigner(
        bytes32 subscriptionHash,
        bytes memory signature
    )
        public
        pure
        returns (address)
    {
        return ECDSA.recover(subscriptionHash, signature);
    }

    function isSubscriptionReady(
        address from,
        address toAddress,
        address tokenAddress,
        uint256 tokenAmount,
        uint256 periodSeconds,
        uint256 nonce,
        bytes memory signature
    )
        external
        view
        returns (bool)
    {
        bytes32 subscriptionHash = getSubscriptionHash(
            from, toAddress, tokenAddress, tokenAmount, periodSeconds, nonce
        );
        address signer = getSubscriptionSigner(subscriptionHash, signature);
        uint256 allowance = ERC20(tokenAddress).allowance(from, address(this));
        uint256 balance = ERC20(tokenAddress).balanceOf(from);

        return (
            signer == from &&
            from != toAddress &&
            isSubscriptionActive(subscriptionHash) &&
            allowance >= tokenAmount &&
            balance >= tokenAmount
        );
    }

    function cancelSubscription(
        address from,
        address toAddress,
        address tokenAddress,
        uint256 tokenAmount,
        uint256 periodSeconds,
        uint256 nonce,
        bytes memory signature
    )
        external
        returns (bool success)
    {
        bytes32 subscriptionHash = getSubscriptionHash(
            from, toAddress, tokenAddress, tokenAmount, periodSeconds, nonce
        );
        address signer = getSubscriptionSigner(subscriptionHash, signature);

        require(signer == from, "Invalid Signature for subscription cancellation");
        require(from == msg.sender, 'msg.sender is not the subscriber');

        nextValidTimestamp[subscriptionHash] = type(uint256).max;

        emit CancelSubscription(
            from, toAddress, tokenAddress, tokenAmount, periodSeconds, nonce
        );

        return true;
    }

    function permit(
        address tokenAddress,
        address owner,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        ERC20Permit token = ERC20Permit(tokenAddress);
        token.permit(owner, address(this), value, deadline, v, r, s);
    }

    function executeSubscription(
        address from,
        address toAddress,
        address tokenAddress,
        uint256 tokenAmount,
        uint256 periodSeconds,
        uint256 nonce,
        bytes memory signature
    )
        public
        returns (bool success)
    {
        bytes32 subscriptionHash = getSubscriptionHash(
            from, toAddress, tokenAddress, tokenAmount, periodSeconds, nonce
        );
        address signer = getSubscriptionSigner(subscriptionHash, signature);

        require(signer == from, "Invalid Signature for subscription execution");
        require(from != toAddress, 'from address is the destination address');
        require(isSubscriptionActive(subscriptionHash), 'Subscription not ready for execution yet');
        uint256 allowance = ERC20(tokenAddress).allowance(from, address(this));
        require(allowance >= tokenAmount, 'Insufficient allowance to execute subscription');
        uint256 balance = ERC20(tokenAddress).balanceOf(from);
        require(balance >= tokenAmount, 'Insufficient balance to execute subscription');

        ERC20(tokenAddress).transferFrom(from, address(this), tokenAmount);
        uint256 reducedAmount = tokenAmount.mul(99).div(100);
        ERC20(tokenAddress).transfer(toAddress, reducedAmount);

        nextValidTimestamp[subscriptionHash] = block.timestamp.add(periodSeconds);

        emit ExecuteSubscription(
            from, toAddress, tokenAddress, tokenAmount, periodSeconds, nonce
        );

        return true;
    }

    function transferRemainingBalance(
        address tokenAddress
    )
        external
        onlyOwner
        returns (bool success)
    {
        uint256 balance = ERC20(tokenAddress).balanceOf(address(this));
        ERC20(tokenAddress).transfer(this.owner(), balance);
        return true;
    }

    function permitSubscription(
        address from,
        address toAddress,
        address tokenAddress,
        uint256 tokenAmount,
        uint256 periodSeconds,
        uint256 nonce,
        bytes memory signature,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        returns (bool success)
    {
        permit(tokenAddress, from, value, deadline, v, r, s);
        return executeSubscription(
            from, toAddress, tokenAddress, tokenAmount, periodSeconds, nonce, signature
        );
    }
}
