# FitnessFusion Protocol

A decentralized fitness incentive system that rewards consistent physical activity on the Stacks blockchain with verifiable NFT achievements.

## Overview

FitnessFusion Protocol is designed to incentivize and reward fitness activities through a tokenized reward system. By completing workouts and maintaining consistency streaks, participants earn tokens that can be claimed or locked in challenges for additional benefits. Additionally, users receive NFT achievement badges as verifiable proof of their fitness milestones.

## Features

- **Workout Completion Rewards**: Earn base tokens for completing fitness activities
- **Consistency Streaks**: Build a streak by working out regularly for bonus rewards
- **Token Challenges**: Lock earned tokens to demonstrate commitment to fitness goals
- **Activity Tracking**: Monitor your fitness progress and completed workouts on-chain
- **NFT Achievement Badges**: Receive unique, transferable NFTs for each workout completion
- **Verifiable Achievements**: Share and prove your fitness milestones with blockchain-backed NFTs

## How It Works

1. **Workout Start**: Users start a workout by specifying the expected intensity
2. **Completion**: Upon completing a workout, users receive base rewards plus streak bonuses and an NFT badge
3. **Streaks**: Maintaining a consistent workout schedule (daily activities) increases streak multipliers
4. **Claiming**: Earned tokens can be claimed at any time
5. **Challenges**: Optional locking of tokens for longer-term fitness commitment benefits
6. **NFT Management**: Achievement badges can be viewed and transferred to other users

## Technical Details

### Reward Structure

- Base workout reward: 10 tokens per activity
- Consistency bonus: 2 additional tokens per streak tier (up to 7 tiers)
- Maximum potential reward per completion: 24 tokens (10 base + 14 consistency bonus)
- Total token reserve: 1,000,000 tokens

### Streak Mechanics

- Daily workout completions build your streak tier
- Missing a day resets your streak to tier 1
- Each tier increases your rewards by 2 tokens
- Maximum streak tier is 7 (for a 14 token bonus)

### Challenge System

- Tokens can be locked in challenges to demonstrate commitment
- Minimum challenge period: 288 blocks (approximately 2 days)
- Early quit penalty: 10% of locked amount
- Successful completion of challenge period returns 100% of locked tokens

### NFT Achievement System

- Each workout completion generates a unique NFT achievement badge
- NFTs contain metadata about the workout intensity, completion date, and streak level
- Achievement badges are transferable between users
- Each user can hold up to 100 achievement badges

## Usage

### For Fitness Enthusiasts

```clarity
;; Start a workout with specified intensity
(contract-call? .fitness-fusion start-workout u100)

;; Complete a workout after required intensity
(contract-call? .fitness-fusion complete-workout u100)

;; Check your current reward balance
(contract-call? .fitness-fusion get-reward-balance tx-sender)

;; Claim your earned rewards
(contract-call? .fitness-fusion claim-rewards)

;; Join a fitness challenge by locking tokens
(contract-call? .fitness-fusion join-challenge u50)

;; Complete a challenge after commitment period
(contract-call? .fitness-fusion complete-challenge)

;; View your NFT achievement badges
(contract-call? .fitness-fusion get-user-badges tx-sender)
;; View platform statistics
(contract-call? .fitness-fusion get-platform-stats)

Getting Started

1. Deploy the FitnessFusion contract to a Stacks blockchain node
2. Start your first workout by calling `start-workout`
3. Complete the workout after the required intensity
4. Build your streak by completing workouts daily
5. Claim or lock your rewards in challenges
6. View and manage your NFT achievement badges

Future Development

- Integration with fitness tracking devices and apps
- Expansion of workout types and specialized fitness paths
- Community challenges and group fitness activities
- Enhanced NFT metadata with visual representations of achievements
- Cross-platform fitness credential verification
- Marketplace for trading achievement badges