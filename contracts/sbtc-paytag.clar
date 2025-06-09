;; Title: sBTC PayTag Protocol
;; Summary: Decentralized payment request system for Bitcoin on Stacks
;; Description: A trustless protocol enabling users to create, share, and fulfill 
;;              Bitcoin payment requests using sBTC tokens. Features include 
;;              expirable payment tags, secure escrow-free transfers, and 
;;              comprehensive state management for seamless Bitcoin payments 
;;              on Stacks Layer 2.

;; Error Codes
(define-constant ERR-TAG-EXISTS u100)
(define-constant ERR-NOT-PENDING u101)
(define-constant ERR-INSUFFICIENT-FUNDS u102)
(define-constant ERR-NOT-FOUND u103)
(define-constant ERR-UNAUTHORIZED u104)
(define-constant ERR-EXPIRED u105)
(define-constant ERR-INVALID-AMOUNT u106)
(define-constant ERR-EMPTY-MEMO u107)
(define-constant ERR-MAX-EXPIRATION-EXCEEDED u108)

;; State Constants
(define-constant STATE-PENDING "pending")
(define-constant STATE-PAID "paid")
(define-constant STATE-EXPIRED "expired")
(define-constant STATE-CANCELED "canceled")

;; Protocol Configuration
;; Official sBTC token contract
(define-constant SBTC-CONTRACT 'ST1F7QA2MDF17S807EPA36TSS8AMEFY4KA9TVGWXT.sbtc-token)

;; Contract owner (for potential upgrades or admin functions)
(define-constant CONTRACT-OWNER tx-sender)

;; Maximum expiration time (30 days in blocks, assuming ~10 min per block)
(define-constant MAX-EXPIRATION-BLOCKS u4320) ;; ~30 days

;; Data Storage Maps

;; Main storage for payment tags with comprehensive metadata
(define-map pay-tags
  { id: uint }
  {
    creator: principal,
    recipient: principal,
    amount: uint,
    created-at: uint,
    expires-at: uint,
    memo: (optional (string-ascii 256)),
    state: (string-ascii 16),
    payment-tx: (optional (buff 32)), ;; Transaction ID when paid
  }
)

;; Index mapping creators to their payment tag IDs
(define-map tags-by-creator
  { creator: principal }
  { ids: (list 50 uint) }
)

;; Index mapping recipients to payment tag IDs assigned to them
(define-map tags-by-recipient
  { recipient: principal }
  { ids: (list 50 uint) }
)

;; State Variables

;; Auto-incrementing counter for unique payment tag IDs
(define-data-var last-id uint u0)

;; Internal Helper Functions

(define-private (add-id-to-principal-list
    (user principal)
    (id uint)
  )
  (let (
      (current-list-data (default-to { ids: (list) } (map-get? tags-by-creator { creator: user })))
      (current-list (get ids current-list-data))
      (new-list (unwrap! (as-max-len? (append current-list id) u50) current-list))
    )
    (begin
      (map-set tags-by-creator { creator: user } { ids: new-list })
      new-list
    )
  )
)