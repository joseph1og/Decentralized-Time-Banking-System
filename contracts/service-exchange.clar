;; Service Exchange Contract

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_NOT_AUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_INVALID_STATUS (err u400))

;; Define service request statuses
(define-constant STATUS_OPEN u1)
(define-constant STATUS_ACCEPTED u2)
(define-constant STATUS_COMPLETED u3)
(define-constant STATUS_CANCELLED u4)

;; Data Maps
(define-map service-requests
  { request-id: uint }
  {
    requester: principal,
    provider: (optional principal),
    skill: (string-ascii 50),
    duration: uint,
    status: uint
  }
)

(define-data-var request-nonce uint u0)

;; Functions
(define-public (create-request (skill (string-ascii 50)) (duration uint))
  (let
    ((new-request-id (+ (var-get request-nonce) u1)))
    (map-set service-requests
      { request-id: new-request-id }
      {
        requester: tx-sender,
        provider: none,
        skill: skill,
        duration: duration,
        status: STATUS_OPEN
      }
    )
    (var-set request-nonce new-request-id)
    (ok new-request-id)
  )
)

(define-public (accept-request (request-id uint))
  (let
    ((request (unwrap! (map-get? service-requests { request-id: request-id }) ERR_NOT_FOUND)))
    (asserts! (is-eq (get status request) STATUS_OPEN) ERR_INVALID_STATUS)
    (ok (map-set service-requests
      { request-id: request-id }
      (merge request { provider: (some tx-sender), status: STATUS_ACCEPTED })
    ))
  )
)

(define-public (complete-service (request-id uint))
  (let
    ((request (unwrap! (map-get? service-requests { request-id: request-id }) ERR_NOT_FOUND)))
    (asserts! (is-eq (some tx-sender) (get provider request)) ERR_NOT_AUTHORIZED)
    (asserts! (is-eq (get status request) STATUS_ACCEPTED) ERR_INVALID_STATUS)
    (ok (map-set service-requests
      { request-id: request-id }
      (merge request { status: STATUS_COMPLETED })
    ))
  )
)

(define-public (cancel-request (request-id uint))
  (let
    ((request (unwrap! (map-get? service-requests { request-id: request-id }) ERR_NOT_FOUND)))
    (asserts! (is-eq tx-sender (get requester request)) ERR_NOT_AUTHORIZED)
    (asserts! (is-eq (get status request) STATUS_OPEN) ERR_INVALID_STATUS)
    (ok (map-set service-requests
      { request-id: request-id }
      (merge request { status: STATUS_CANCELLED })
    ))
  )
)

(define-read-only (get-request (request-id uint))
  (map-get? service-requests { request-id: request-id })
)

