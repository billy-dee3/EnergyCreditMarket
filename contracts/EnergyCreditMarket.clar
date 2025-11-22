
;; Energy Credit Market Contract v1.0

;; NFT definition
(define-non-fungible-token energy-credit uint)

;; Constants for errors
(define-constant err-not-admin (err u100))
(define-constant err-not-found (err u101))
(define-constant err-not-authorized (err u102))
(define-constant err-invalid-args (err u103))
(define-constant err-mint-failed (err u104))
(define-constant err-already-listed (err u105))
(define-constant err-not-listed (err u106))
(define-constant err-transfer-failed (err u107))

;; State variables
(define-data-var admin principal tx-sender)
(define-data-var treasury principal tx-sender)
(define-data-var project-counter uint u0)
(define-data-var token-counter uint u0)

;; Data maps
(define-map projects 
  { id: uint } 
  { owner: principal, 
    metadata: (buff 64), 
    cap: uint, 
    minted: uint, 
    verified: bool 
  }
)

(define-map producers 
  { project-id: uint, who: principal } 
  { approved: bool }
)

(define-map token-info 
  { token-id: uint } 
  { project-id: uint, retired: bool }
)

(define-map listings 
  { token-id: uint } 
  { seller: principal, price: uint }
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Helper functions
(define-private (is-admin)
  (is-eq tx-sender (var-get admin)))

(define-private (is-valid-project (project-id uint))
  (is-some (map-get? projects {id: project-id})))

(define-private (is-valid-token (token-id uint))
  (and
    (>= token-id u0)
    (<= token-id (var-get token-counter))))

(define-public (set-treasury (who principal))
  (begin
    (asserts! (is-admin) err-not-admin)
    (var-set treasury who)
    (ok true)))

;; register a new project
(define-public (register-project (metadata (buff 64)) (cap uint) (verified bool))
  (let ((id (+ u1 (var-get project-counter))))
    (begin
      (asserts! (> cap u0) err-invalid-args)
      (var-set project-counter id)
      (map-set projects 
        {id: id} 
        {owner: tx-sender, metadata: metadata, cap: cap, minted: u0, verified: verified})
      (ok id))))

(define-public (approve-producer (project-id uint) (who principal) (approve bool))
  (begin
    (asserts! (is-admin) err-not-admin)
    (asserts! (not (is-none (map-get? projects { id: project-id }))) err-not-found)
    (ok (map-set producers 
         { project-id: project-id, who: who } 
         { approved: approve }))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mint a single credit
(define-public (mint-one-credit (project-id uint))
  (let ((next-id (+ u1 (var-get token-counter))))
    (match (nft-mint? energy-credit next-id tx-sender)
      error err-mint-failed
      success (begin
        (var-set token-counter next-id)
        (map-set token-info 
          { token-id: next-id } 
          { project-id: project-id, retired: false })
        (ok next-id)))))

(define-public (mint-credits (project-id uint) (quantity uint) (uri (string-ascii 64)))
  (let 
    ((project (unwrap! (map-get? projects { id: project-id }) err-not-found))
     (producer (unwrap! (map-get? producers { project-id: project-id, who: tx-sender }) err-not-authorized)))
    (begin
      (asserts! (get approved producer) err-not-authorized)
      (asserts! (<= (+ (get minted project) quantity) (get cap project)) err-invalid-args)
      (ok (var-get token-counter)))))

;; Listing: seller escrows token by transferring token -> contract
(define-public (list-for-sale (token-id uint) (price uint))
  (begin
    (asserts! (> price u0) err-invalid-args)
    (asserts! (is-eq (some tx-sender) (nft-get-owner? energy-credit token-id)) err-not-authorized)
    (asserts! (not (is-some (map-get? listings {token-id: token-id}))) err-already-listed)
    (map-set listings 
      {token-id: token-id} 
      {seller: tx-sender, price: price})
    (ok true)))

;; Cancel listing: seller gets NFT back
(define-public (cancel-listing (token-id uint))
  (let ((listing (unwrap! (map-get? listings {token-id: token-id}) err-not-listed)))
    (begin
      (asserts! (is-eq tx-sender (get seller listing)) err-not-authorized)
      (map-delete listings {token-id: token-id})
      (ok true))))

;; Buy listed credit: buyer sends STX, contract transfers STX to seller and NFT to buyer
(define-public (buy-credit (token-id uint))
  (let 
    ((listing (unwrap! (map-get? listings {token-id: token-id}) err-not-listed))
     (seller (get seller listing))
     (price (get price listing)))
    (begin
      (try! (stx-transfer? price tx-sender seller))
      (map-delete listings {token-id: token-id})
      (ok true))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Retire credit: owner marks token as retired (only owner can retire)
(define-public (retire-credit (token-id uint))
  (let 
    ((owner (unwrap! (nft-get-owner? energy-credit token-id) err-not-authorized))
     (token (unwrap! (map-get? token-info {token-id: token-id}) err-invalid-args)))
    (begin
      (asserts! (is-eq tx-sender owner) err-not-authorized)
      (asserts! (not (get retired token)) err-already-listed)
      (ok (map-set token-info 
           {token-id: token-id} 
           {project-id: (get project-id token), retired: true})))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Admin withdraws STX collected in contract
(define-public (withdraw (to principal) (amount uint))
  (begin
    (asserts! (is-admin) err-not-admin)
    (try! (stx-transfer? amount tx-sender to))
    (ok true)))

(define-public (withdraw-all-to-treasury)
  (begin
    (asserts! (is-admin) err-not-admin)
    (let ((balance (stx-get-balance tx-sender)))
      (try! (stx-transfer? balance tx-sender (var-get treasury)))
      (ok balance))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Read-only getters
(define-read-only (get-project (id uint)) (map-get? projects {id: id}))
(define-read-only (is-producer-approved (project-id uint) (who principal))
  (default-to false (get approved (map-get? producers {project-id: project-id, who: who}))))
(define-read-only (get-token-info (id uint)) (map-get? token-info {token-id: id}))
(define-read-only (get-listing (token-id uint)) (map-get? listings {token-id: token-id}))
(define-read-only (get-treasury) (var-get treasury))
(define-read-only (get-admin) (ok (var-get admin)))
