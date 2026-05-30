# TechConnect Road Map & Brief

TechConnect is a professional match platform designed for developers, designers, product managers, and other tech practitioners to connect based on shared technology interests, career goals, and experience levels.

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Mobile | Swift + SwiftUI (iOS 16+) |
| Backend | Java 21 + Spring Boot 3.x |
| Database | PostgreSQL 16 |
| Messaging | Spring WebSocket (STOMP) |
| Auth | JWT + Apple Sign In + GitHub OAuth |
| Subscription | RevenueCat (Entitlement: `pro`) |
| Storage | Cloudflare R2 (S3-compatible) |
| Push Notifications | Firebase Cloud Messaging (FCM) |

---

## 📊 Relational Database Schema

### 1. `users`
- `id` (uuid, primary key)
- `email` (varchar, unique, not null)
- `display_name` (varchar)
- `auth_provider` (enum: apple, github)
- `mode` (enum: network, dating, both) — Network default for MVP
- `subscription_tier` (enum: free, pro)
- `is_active` (boolean)
- `created_at` / `updated_at` (timestamp)

### 2. `profiles`
- `id` (uuid, primary key)
- `user_id` (uuid, foreign key → users, unique)
- `role` (varchar, e.g., Backend Developer, PM, Designer)
- `experience_years` (int)
- `sector` (enum: startup, corporate, freelance)
- `bio` (text, max 300)
- `looking_for` (enum: mentor, mentee, collaboration, coffee_chat)
- `city` (varchar)
- `is_remote` (boolean)
- `created_at` / `updated_at` (timestamp)

### 3. `tech_stacks`
- `id` (uuid, primary key)
- `profile_id` (uuid, foreign key → profiles)
- `technology` (varchar, e.g., Go, Swift, Docker)
- `created_at` / `updated_at` (timestamp)

### 4. `photos`
- `id` (uuid, primary key)
- `user_id` (uuid, foreign key → users)
- `r2_key` (varchar)
- `position` (int, sorting order)
- `created_at` / `updated_at` (timestamp)

### 5. `swipes`
- `id` (uuid, primary key)
- `swiper_id` (uuid, foreign key → users)
- `target_id` (uuid, foreign key → users)
- `direction` (enum: like, pass)
- Unique Constraint: `(swiper_id, target_id)`
- `created_at` / `updated_at` (timestamp)

### 6. `matches`
- `id` (uuid, primary key)
- `user_a_id` (uuid, foreign key → users)
- `user_b_id` (uuid, foreign key → users)
- `matched_at` (timestamp)
- `created_at` / `updated_at` (timestamp)

### 7. `messages`
- `id` (uuid, primary key)
- `match_id` (uuid, foreign key → matches)
- `sender_id` (uuid, foreign key → users)
- `content` (text)
- `sent_at` (timestamp)
- `is_read` (boolean)
- `created_at` / `updated_at` (timestamp)

### 8. `coffee_chat_requests`
- `id` (uuid, primary key)
- `match_id` (uuid, foreign key → matches)
- `requester_id` (uuid, foreign key → users)
- `proposed_time` (timestamp)
- `status` (enum: pending, accepted, declined)
- `created_at` / `updated_at` (timestamp)

---

## 🧮 Matching Algorithm (Network Mode)

```
score = (shared_technologies_count * 3)
      + (same_sector ? 2 : 0)
      + (looking_for_compatibility ? 4 : 0) // mentor <-> mentee, collaboration <-> collaboration
      + (experience_years_diff <= 3 ? 1 : 0)
      - (already_swiped ? 1000 : 0)         // excludes from discover deck
```

---

## 🎯 Development Phases

### Phase 1: MVP Skeletons & Setup (Current)
- Setup workspace structure, local git, and GitHub connection.
- Spring Boot boilerplate and configuration setting.
- SwiftUI Xcode template setup (compiles out-of-the-box).

### Phase 2: Core Network Development
- Database models, Flyway schema migrations, and REST controllers.
- JWT Security structure, Social Auth integration (mock/sandbox).
- Matching service algorithm implementation and swipes/matching logic.
- SwiftUI Views (Login gradient UI, Profile Form with tags flow, drag cards Deck swiper, Match overlay, Connections list).

### Phase 3: Messaging, Payments & Dating Mode
- Spring WebSocket (STOMP) real-time chatting backend.
- RevenueCat webhook integration to sync entitlement access tiers.
- Enable Dating mode profiles.
- advanced filters (e.g. hide coworkers - corporate email domain filter).
