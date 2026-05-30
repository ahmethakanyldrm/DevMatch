-- 1. Create Developer Profiles Table
CREATE TABLE developer_profiles (
    id UUID PRIMARY KEY,
    display_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    role VARCHAR(100) NOT NULL,
    experience_years INT NOT NULL,
    sector VARCHAR(50) NOT NULL,
    bio VARCHAR(300),
    looking_for VARCHAR(50) NOT NULL,
    city VARCHAR(100),
    is_remote BOOLEAN NOT NULL DEFAULT FALSE,
    tech_stack VARCHAR(500),
    photo_names VARCHAR(500),
    subscription_tier VARCHAR(20) NOT NULL DEFAULT 'free'
);

-- 2. Create Swipes Table
CREATE TABLE swipes (
    id UUID PRIMARY KEY,
    liker_id UUID NOT NULL REFERENCES developer_profiles(id) ON DELETE CASCADE,
    liked_id UUID NOT NULL REFERENCES developer_profiles(id) ON DELETE CASCADE,
    swipe_type VARCHAR(10) NOT NULL, -- 'LIKE' or 'PASS'
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_swipe UNIQUE (liker_id, liked_id)
);

-- 3. Create Matches Table
CREATE TABLE matches (
    id UUID PRIMARY KEY,
    profile_1_id UUID NOT NULL REFERENCES developer_profiles(id) ON DELETE CASCADE,
    profile_2_id UUID NOT NULL REFERENCES developer_profiles(id) ON DELETE CASCADE,
    matched_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_match UNIQUE (profile_1_id, profile_2_id)
);

-- 4. Create Messages Table
CREATE TABLE messages (
    id UUID PRIMARY KEY,
    match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES developer_profiles(id) ON DELETE CASCADE,
    content VARCHAR(1000) NOT NULL,
    sent_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN NOT NULL DEFAULT FALSE
);

-- 5. Create Coffee Chat Requests Table
CREATE TABLE coffee_chat_requests (
    id UUID PRIMARY KEY,
    match_id UUID NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    requester_id UUID NOT NULL REFERENCES developer_profiles(id) ON DELETE CASCADE,
    proposed_time TIMESTAMP NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' -- 'PENDING', 'ACCEPTED', 'DECLINED'
);
