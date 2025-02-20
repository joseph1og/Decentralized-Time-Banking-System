;; Community Governance Contract

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_INVALID_STATUS (err u400))

;; Define proposal statuses
(define-constant STATUS_ACTIVE u1)
(define-constant STATUS_PASSED u2)
(define-constant STATUS_REJECTED u3)

;; Data Maps
(define-map proposals
  { proposal-id: uint }
  {
    proposer: principal,
    description: (string-utf8 500),
    votes-for: uint,
    votes-against: uint,
    status: uint,
    end-block: uint
  }
)

(define-map votes
  { proposal-id: uint, voter: principal }
  { vote: bool }
)

(define-data-var proposal-nonce uint u0)

;; Functions
(define-public (create-proposal (description (string-utf8 500)) (voting-period uint))
  (let
    ((new-proposal-id (+ (var-get proposal-nonce) u1)))
    (map-set proposals
      { proposal-id: new-proposal-id }
      {
        proposer: tx-sender,
        description: description,
        votes-for: u0,
        votes-against: u0,
        status: STATUS_ACTIVE,
        end-block: (+ block-height voting-period)
      }
    )
    (var-set proposal-nonce new-proposal-id)
    (ok new-proposal-id)
  )
)

(define-public (vote (proposal-id uint) (vote-for bool))
  (let
    ((proposal (unwrap! (map-get? proposals { proposal-id: proposal-id }) ERR_NOT_FOUND)))
    (asserts! (< block-height (get end-block proposal)) ERR_INVALID_STATUS)
    (asserts! (is-none (map-get? votes { proposal-id: proposal-id, voter: tx-sender })) ERR_NOT_AUTHORIZED)
    (map-set votes { proposal-id: proposal-id, voter: tx-sender } { vote: vote-for })
    (ok (map-set proposals
      { proposal-id: proposal-id }
      (merge proposal {
        votes-for: (if vote-for (+ (get votes-for proposal) u1) (get votes-for proposal)),
        votes-against: (if vote-for (get votes-against proposal) (+ (get votes-against proposal) u1))
      })
    ))
  )
)

(define-public (end-proposal (proposal-id uint))
  (let
    ((proposal (unwrap! (map-get? proposals { proposal-id: proposal-id }) ERR_NOT_FOUND)))
    (asserts! (>= block-height (get end-block proposal)) ERR_INVALID_STATUS)
    (asserts! (is-eq (get status proposal) STATUS_ACTIVE) ERR_INVALID_STATUS)
    (ok (map-set proposals
      { proposal-id: proposal-id }
      (merge proposal {
        status: (if (> (get votes-for proposal) (get votes-against proposal)) STATUS_PASSED STATUS_REJECTED)
      })
    ))
  )
)

(define-read-only (get-proposal (proposal-id uint))
  (map-get? proposals { proposal-id: proposal-id })
)

(define-read-only (get-vote (proposal-id uint) (voter principal))
  (map-get? votes { proposal-id: proposal-id, voter: voter })
)

