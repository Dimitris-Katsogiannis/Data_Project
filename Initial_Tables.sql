-- Table to store information about conversations
create or replace TABLE RawData.Conversations (
    payment_id INTEGER NOT NULL,
    payment_token_id INTEGER NOT NULL,
    external_ticket_id INTEGER NOT NULL,
    conversation_created_at TIMESTAMP NOT NULL,
    conversation_created_at_date DATE NOT NULL,
    channel STRING NOT NULL,
    assignee_id INTEGER NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    closed_at TIMESTAMP,
    message_count INTEGER NOT NULL,
    last_reply_at TIMESTAMP,
    language STRING NOT NULL,
    imported_at TIMESTAMP NOT NULL,
    unique_public_agent_count INTEGER NOT NULL,
    public_mean_character_count FLOAT64 NOT NULL,
    public_mean_word_count FLOAT64 NOT NULL,
    private_message_count INTEGER NOT NULL,
    public_message_count INTEGER NOT NULL,
    klaus_sentiment STRING NOT NULL,
    is_closed BOOLEAN NOT NULL,
    agent_most_public_messages INTEGER NOT NULL,
    first_response_time INTEGER,
    first_resolution_time_seconds INTEGER,
    full_resolution_time_seconds INTEGER,
    most_active_internal_user_id INTEGER,
    deleted_at DATETIME,
    PRIMARY KEY (external_ticket_id) NOT ENFORCED
);

-- Table to store AutoQA reviews
create or replace TABLE RawData.Autoqa_Reviews (
    autoqa_review_id STRING NOT NULL,
    payment_id INTEGER NOT NULL,
    payment_token_id INTEGER NOT NULL,
    external_ticket_id INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL,
    conversation_created_at TIMESTAMP NOT NULL,
    conversation_created_date DATE NOT NULL,
    team_id INTEGER NOT NULL,
    reviewee_internal_id INTEGER ,
    updated_at TIMESTAMP NOT NULL,
    PRIMARY KEY (autoqa_review_id) NOT ENFORCED
);

-- Table to store AutoQA ratings associated with reviews
create or replace TABLE RawData.Autoqa_Ratings (
    autoqa_review_id STRING NOT NULL,
    autoqa_rating_id STRING NOT NULL,
    payment_id INTEGER NOT NULL,
    team_id INTEGER NOT NULL,
    payment_token_id INTEGER NOT NULL,
    external_ticket_id INTEGER NOT NULL,
    rating_category_id INTEGER NOT NULL,
    rating_category_name STRING NOT NULL,
    rating_scale_score INTEGER ,
    score INTEGER ,
    reviewee_internal_id INTEGER NOT NULL,
    PRIMARY KEY (autoqa_rating_id) NOT ENFORCED
);

-- Table to store manual ratings
create or replace TABLE RawData.Manual_Ratings (
    payment_id INTEGER NOT NULL,
    team_id INTEGER NOT NULL,
    review_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    rating INTEGER ,
    cause STRING NOT NULL,
    rating_max INTEGER NOT NULL,
    weight FLOAT64 NOT NULL,
    critical BOOLEAN NOT NULL,
    category_name STRING ,
    PRIMARY KEY (review_id) NOT ENFORCED
);

-- Table to store manual reviews
create or replace TABLE RawData.Manual_Reviews (
    review_id INTEGER NOT NULL,
    payment_id INTEGER NOT NULL,
    payment_token_id INTEGER NOT NULL,
    created DATETIME NOT NULL,
    conversation_created_at TIMESTAMP ,
    conversation_created_date DATE ,
    conversation_external_id INTEGER NOT NULL,
    team_id INTEGER NOT NULL,
    reviewer_id INTEGER NOT NULL,
    reviewee_id INTEGER NOT NULL,
    comment_id INTEGER ,
    scorecard_id INTEGER ,
    scorecard_tag STRING ,
    score FLOAT64 NOT NULL,
    updated_at DATETIME NOT NULL,
    updated_by INTEGER NOT NULL,
    assignment_review BOOLEAN NOT NULL,
    seen BOOLEAN NOT NULL,
    disputed BOOLEAN NOT NULL,
    review_time_seconds FLOAT64 ,
    assignment_name STRING ,
    imported_at DATETIME NOT NULL,
    PRIMARY KEY (review_id) NOT ENFORCED
);

-- Adding a foreign key constraint to 'Manual_Reviews'
ALTER TABLE RawData.Manual_Reviews
ADD CONSTRAINT fk_manual_reviews_external_ticket_id
FOREIGN KEY (conversation_external_id) REFERENCES RawData.Conversations(external_ticket_id) NOT ENFORCED;

-- Adding a foreign key constraint to 'Autoqa_Reviews'
ALTER TABLE RawData.Autoqa_Reviews
ADD CONSTRAINT fk_autoqa_reviews_external_ticket_id
FOREIGN KEY (external_ticket_id) REFERENCES RawData.Conversations(external_ticket_id) NOT ENFORCED;

-- Adding a foreign key constraint to 'Autoqa_Ratings'
ALTER TABLE RawData.Autoqa_Ratings
ADD CONSTRAINT fk_autoqa_external_ticket_id
FOREIGN KEY (external_ticket_id) REFERENCES RawData.Conversations(external_ticket_id) NOT ENFORCED;

-- Adding a foreign key constraint to 'Manual_Ratings'
ALTER TABLE RawData.Manual_Ratings
ADD CONSTRAINT fk_manual_review_id
FOREIGN KEY (review_id) REFERENCES RawData.Manual_Reviews(review_id) NOT ENFORCED;
