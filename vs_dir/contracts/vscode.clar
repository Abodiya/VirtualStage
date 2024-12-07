;; Virtual Concert Ticket Platform - Enhanced Version
;; Added performance details, ticket pricing, and stream quality

;; Constants for viewer tiers
(define-constant STANDARD u1)
(define-constant VIP u2)
(define-constant BACKSTAGE u3)

;; Constants for validation
(define-constant MIN-STREAM-QUALITY u60)
(define-constant MINIMUM-TICKET-PRICE u100)

;; Error codes
(define-constant ERR-UNAUTHORIZED (err u401))
(define-constant ERR-INVALID-PARAMS (err u400))
(define-constant ERR-NOT-FOUND (err u404))
(define-constant ERR-INSUFFICIENT-FUNDS (err u402))

;; Data structures
(define-map virtual-events
  { event-id: uint }
  {
    artist: principal,
    event-timestamp: uint,
    genre: (string-utf8 64),
    venue-name: (string-utf8 128),
    scheduled: bool,
    stream-quality: uint
  }
)

(define-map performance-details
  { event-id: uint }
  {
    stream-key: (buff 32),
    quality-level: uint,
    ticket-price: uint,
    setlist: (string-utf8 256),
    last-updated: uint
  }
)

;; Principal variables
(define-data-var contract-owner principal tx-sender)

;; Event scheduling function
(define-public (schedule-event 
    (event-id uint)
    (genre (string-utf8 64))
    (venue-name (string-utf8 128))
    (event-timestamp uint))
  (begin
    (asserts! (> event-id u0) ERR-INVALID-PARAMS)
    (asserts! (> (len genre) u0) ERR-INVALID-PARAMS)
    (asserts! (> (len venue-name) u0) ERR-INVALID-PARAMS)
    (asserts! (> event-timestamp u0) ERR-INVALID-PARAMS)
    (ok (map-set virtual-events
      {event-id: event-id}
      {
        artist: tx-sender,
        event-timestamp: event-timestamp,
        genre: genre,
        venue-name: venue-name,
        scheduled: true,
        stream-quality: u100
      }))))

;; Performance details submission
(define-public (submit-performance-details
    (event-id uint)
    (stream-key (buff 32))
    (ticket-price uint)
    (setlist (string-utf8 256))
    (timestamp uint))
  (let
    ((event (unwrap! (map-get? virtual-events {event-id: event-id}) ERR-NOT-FOUND)))
    (begin
      (asserts! (is-eq (get artist event) tx-sender) ERR-UNAUTHORIZED)
      (asserts! (get scheduled event) ERR-UNAUTHORIZED)
      (asserts! (>= ticket-price MINIMUM-TICKET-PRICE) ERR-INVALID-PARAMS)
      (ok (map-set performance-details
        {event-id: event-id}
        {
          stream-key: stream-key,
          quality-level: u100,
          ticket-price: ticket-price,
          setlist: setlist,
          last-updated: timestamp
        })))))

;; Read-only functions
(define-read-only (get-event-info (event-id uint))
  (map-get? virtual-events {event-id: event-id}))

(define-read-only (get-performance-details (event-id uint))
  (map-get? performance-details {event-id: event-id}))