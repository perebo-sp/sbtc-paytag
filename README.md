# sBTC PayTag Protocol

A decentralized payment request system for Bitcoin on Stacks Layer 2, enabling trustless payment workflows using sBTC tokens.

## Overview

The sBTC PayTag Protocol provides a comprehensive solution for creating, managing, and fulfilling Bitcoin payment requests on the Stacks blockchain. Built around sBTC tokens, it offers a secure, escrow-free payment system with built-in expiration mechanics and comprehensive state management.

## Features

- **Trustless Payment Requests**: Create payment tags without requiring escrow or intermediaries
- **Expirable Tags**: Built-in expiration mechanism prevents stale payment requests
- **Comprehensive State Management**: Track payment lifecycle from creation to fulfillment
- **Batch Operations**: Optimized functions for handling multiple payment tags
- **Secure Authorization**: Role-based access control for tag management
- **Event Logging**: Complete audit trail of all payment activities

## System Architecture

### Core Components

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   PayTag        │    │   State          │    │   sBTC Token    │
│   Storage       │    │   Management     │    │   Contract      │
│                 │◄──►│                  │◄──►│                 │
│ • pay-tags      │    │ • pending        │    │ • transfer      │
│ • creator-index │    │ • paid           │    │ • balance       │
│ • recipient-idx │    │ • expired        │    │                 │
└─────────────────┘    │ • canceled       │    └─────────────────┘
                       └──────────────────┘
```

### Contract Architecture

The protocol consists of several key architectural layers:

#### 1. Data Layer

- **Primary Storage**: `pay-tags` map containing complete payment tag metadata
- **Indexing System**: Creator and recipient indices for efficient querying
- **State Variables**: Auto-incrementing ID counter for unique tag identification

#### 2. Validation Layer

- **Input Validation**: Comprehensive checks for amounts, expiration, and memo data
- **State Validation**: Ensures proper state transitions and authorization
- **Security Validation**: Prevents self-payment exploits and unauthorized access

#### 3. Business Logic Layer

- **Tag Creation**: Handles payment request generation with configurable parameters
- **Payment Fulfillment**: Manages sBTC transfers and state updates
- **Lifecycle Management**: Supports cancellation and expiration workflows

#### 4. Integration Layer

- **sBTC Integration**: Direct integration with official sBTC token contract
- **Event System**: Comprehensive logging for external system integration

## Data Flow

### Payment Tag Creation Flow

```
User Request → Input Validation → ID Generation → State Storage → Index Update → Event Emission
```

1. **Request Initiation**: User calls `create-pay-tag` with amount, expiration, and optional memo
2. **Validation Phase**: System validates input parameters and expiration limits
3. **Tag Generation**: New unique ID assigned and payment tag created
4. **Index Management**: Creator and recipient indices updated for efficient retrieval
5. **Event Logging**: Creation event emitted for external monitoring

### Payment Fulfillment Flow

```
Payment Request → Authorization Check → sBTC Transfer → State Update → Event Emission
```

1. **Fulfillment Request**: Payer calls `fulfill-pay-tag` with tag ID
2. **Validation**: System checks tag existence, state, and expiration status
3. **Transfer Execution**: sBTC tokens transferred from payer to recipient
4. **State Transition**: Tag marked as paid with transaction metadata
5. **Event Logging**: Payment completion event emitted

## Core Functions

### Public Functions

| Function | Description | Parameters |
|----------|-------------|------------|
| `create-pay-tag` | Creates new payment request | `amount`, `expires-in`, `memo` |
| `fulfill-pay-tag` | Fulfills existing payment tag | `id` |
| `cancel-pay-tag` | Cancels pending payment tag | `id` |
| `mark-expired` | Marks expired tags as expired | `id` |
| `get-multiple-tags` | Batch retrieval of payment tags | `ids` |

### Read-Only Functions

| Function | Description | Returns |
|----------|-------------|---------|
| `get-pay-tag` | Retrieves specific payment tag | Complete tag data |
| `get-creator-tags` | Gets tags created by user | List of tag IDs |
| `get-recipient-tags` | Gets tags for recipient | List of tag IDs |
| `check-tag-expired` | Checks expiration status | Boolean result |

## State Management

The protocol manages four distinct states for payment tags:

- **PENDING**: Newly created, awaiting payment
- **PAID**: Successfully fulfilled with sBTC transfer
- **EXPIRED**: Past expiration block height
- **CANCELED**: Manually canceled by creator

## Security Features

### Access Control

- Creator-only cancellation rights
- Anti-self-payment protection
- Expiration-based automatic invalidation

### Input Validation

- Amount positivity checks
- Expiration limit enforcement (30 days maximum)
- Memo length validation
- Overflow protection

### State Integrity

- Atomic state transitions
- Comprehensive error handling
- Event-driven audit trail

## Configuration

### Protocol Constants

- **Maximum Expiration**: 4,320 blocks (~30 days)
- **sBTC Contract**: Official Stacks sBTC token integration
- **Index Limits**: Up to 50 tags per user for efficient storage

## Error Handling

The protocol includes comprehensive error codes for robust error handling:

- `ERR-TAG-EXISTS` (100): Tag ID collision
- `ERR-NOT-PENDING` (101): Invalid state transition
- `ERR-INSUFFICIENT-FUNDS` (102): Inadequate sBTC balance
- `ERR-NOT-FOUND` (103): Tag does not exist
- `ERR-UNAUTHORIZED` (104): Access denied
- `ERR-EXPIRED` (105): Tag past expiration
- `ERR-INVALID-AMOUNT` (106): Invalid amount parameter
- `ERR-EMPTY-MEMO` (107): Invalid memo format
- `ERR-MAX-EXPIRATION-EXCEEDED` (108): Expiration too long

## Integration Guide

### Creating Payment Tags

```clarity
(contract-call? .sbtc-paytag create-pay-tag u1000000 u144 (some "Invoice #123"))
```

### Fulfilling Payments

```clarity
(contract-call? .sbtc-paytag fulfill-pay-tag u1)
```

### Querying User Tags

```clarity
(contract-call? .sbtc-paytag get-creator-tags 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

## Events

The protocol emits structured events for external system integration:

- `pay-tag-created`: New payment tag creation
- `pay-tag-paid`: Successful payment fulfillment
- `pay-tag-canceled`: Manual tag cancellation
- `pay-tag-expired`: Automatic expiration marking
