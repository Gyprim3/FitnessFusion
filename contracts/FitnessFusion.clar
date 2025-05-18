;; FitnessFusion Protocol
;; A decentralized fitness incentive system with NFT achievements

;; Constants
(define-constant MAX_TOKEN_RESERVE u1000000)
(define-constant BASE_WORKOUT_REWARD u10)
(define-constant CONSISTENCY_BONUS u2)
(define-constant MAX_CONSISTENCY_TIER u7)
(define-constant ERR_INVALID_WORKOUT u1)
(define-constant ERR_NO_REWARDS u2)
(define-constant ERR_RESERVE_EMPTY u3)
(define-constant BLOCKS_PER_DAY u144)
(define-constant CHALLENGE_BONUS u2)
(define-constant MIN_CHALLENGE_PERIOD u288)
(define-constant EARLY_QUIT_PENALTY u10)

;; Data Variables
(define-data-var total-tokens-issued uint u0)
(define-data-var total-workouts-completed uint u0)
(define-data-var platform-administrator principal tx-sender)
(define-data-var last-badge-id uint u0)

;; Data Maps
(define-map user-workouts principal uint)
(define-map user-rewards principal uint)
(define-map workout-start-block principal uint)
(define-map fitness-streak principal uint)
(define-map last-workout-block principal uint)
(define-map locked-tokens principal uint)
(define-map lock-start-block principal uint)

;; NFT Data Maps
(define-map badge-ownership {id: uint} {owner: principal})
(define-map badge-metadata {id: uint} {workout-intensity: uint, completion-block: uint, streak-level: uint})
(define-map user-badges principal (list 100 uint))

;; Public Functions

(define-public (start-workout (intensity uint))
  (begin
    (asserts! (> intensity u0) (err ERR_INVALID_WORKOUT))
    (map-set workout-start-block tx-sender burn-block-height)
    (ok true)
  )
)

(define-public (complete-workout (intensity uint))
  (let ((start-block (default-to u0 (map-get? workout-start-block tx-sender))))
    (asserts! (> start-block u0) (err ERR_INVALID_WORKOUT))
    (asserts! (>= (- burn-block-height start-block) intensity) (err ERR_INVALID_WORKOUT))
    
    (let ((previous-workout-block (default-to u0 (map-get? last-workout-block tx-sender)))
          (streak (default-to u0 (map-get? fitness-streak tx-sender)))
          (new-streak (if (< (- burn-block-height previous-workout-block) BLOCKS_PER_DAY)
                        (+ streak u1)
                        u1))
          (capped-streak (if (<= streak MAX_CONSISTENCY_TIER) streak MAX_CONSISTENCY_TIER))
          (reward-amount (+ BASE_WORKOUT_REWARD (* capped-streak CONSISTENCY_BONUS)))
          (badge-id (+ (var-get last-badge-id) u1)))
      
      ;; Update user records
      (map-set user-workouts tx-sender (+ (default-to u0 (map-get? user-workouts tx-sender)) u1))
      (map-set user-rewards tx-sender (+ (default-to u0 (map-get? user-rewards tx-sender)) reward-amount))
      (map-set fitness-streak tx-sender new-streak)
      (map-set last-workout-block tx-sender burn-block-height)
      
      ;; Update platform stats
      (var-set total-workouts-completed (+ (var-get total-workouts-completed) u1))
      (var-set total-tokens-issued (+ (var-get total-tokens-issued) reward-amount))
      (asserts! (<= (var-get total-tokens-issued) MAX_TOKEN_RESERVE) (err ERR_RESERVE_EMPTY))
      
      ;; Mint NFT achievement badge
      (var-set last-badge-id badge-id)
      (map-set badge-ownership {id: badge-id} {owner: tx-sender})
      (map-set badge-metadata {id: badge-id} {workout-intensity: intensity, completion-block: burn-block-height, streak-level: capped-streak})
      
      ;; Add badge to user's collection
      (let ((user-badge-list (default-to (list) (map-get? user-badges tx-sender))))
        (map-set user-badges tx-sender (unwrap-panic (as-max-len? (append user-badge-list badge-id) u100)))
        (ok reward-amount)
      )
    )
  )
)

(define-public (claim-rewards)
  (let ((reward-balance (default-to u0 (map-get? user-rewards tx-sender))))
    (asserts! (> reward-balance u0) (err ERR_NO_REWARDS))
    (map-set user-rewards tx-sender u0)
    (ok reward-balance)
  )
)

;; Challenge Features

(define-public (join-challenge (amount uint))
  (begin
    (asserts! (> amount u0) (err ERR_INVALID_WORKOUT))
    (asserts! (>= (var-get total-tokens-issued) amount) (err ERR_RESERVE_EMPTY))
    (map-set locked-tokens tx-sender amount)
    (map-set lock-start-block tx-sender burn-block-height)
    (var-set total-tokens-issued (- (var-get total-tokens-issued) amount))
    (ok amount)
  )
)

(define-public (complete-challenge)
  (let ((locked-amount (default-to u0 (map-get? locked-tokens tx-sender)))
        (lock-block (default-to u0 (map-get? lock-start-block tx-sender))))
    
    (asserts! (> locked-amount u0) (err ERR_NO_REWARDS))
    
    (let ((blocks-locked (- burn-block-height lock-block))
          (penalty (if (< blocks-locked MIN_CHALLENGE_PERIOD) 
                     (/ (* locked-amount EARLY_QUIT_PENALTY) u100) 
                     u0))
          (final-amount (- locked-amount penalty)))
      
      (map-set locked-tokens tx-sender u0)
      (map-set lock-start-block tx-sender u0)
      (var-set total-tokens-issued (+ (var-get total-tokens-issued) final-amount))
      (ok final-amount)
    )
  )
)

;; Read-Only Functions

(define-read-only (get-completed-workouts (user principal))
  (default-to u0 (map-get? user-workouts user))
)

(define-read-only (get-reward-balance (user principal))
  (default-to u0 (map-get? user-rewards user))
)

(define-read-only (get-fitness-streak (user principal))
  (default-to u0 (map-get? fitness-streak user))
)

(define-read-only (get-platform-stats)
  {
    total-workouts-completed: (var-get total-workouts-completed),
    total-tokens-issued: (var-get total-tokens-issued),
    total-badges-issued: (var-get last-badge-id)
  }
)

;; NFT Read-Only Functions

(define-read-only (get-badge-owner (badge-id uint))
  (let ((badge-data (map-get? badge-ownership {id: badge-id})))
    (if (is-some badge-data)
        (some (get owner (unwrap-panic badge-data)))
        none
    )
  )
)

(define-read-only (get-badge-metadata (badge-id uint))
  (map-get? badge-metadata {id: badge-id})
)

(define-read-only (get-user-badges (user principal))
  (default-to (list) (map-get? user-badges user))
)

(define-read-only (get-badge-count)
  (var-get last-badge-id)
)

;; Private Functions

(define-private (is-platform-administrator)
  (is-eq tx-sender (var-get platform-administrator))
)