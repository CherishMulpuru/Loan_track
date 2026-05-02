-- V1__init_schema.sql
-- LoanTrack Initial Database Schema

CREATE TABLE users (
    id          BIGSERIAL PRIMARY KEY,
    email       VARCHAR(255) NOT NULL UNIQUE,
    password    VARCHAR(255) NOT NULL,
    first_name  VARCHAR(100) NOT NULL,
    last_name   VARCHAR(100) NOT NULL,
    phone       VARCHAR(20),
    role        VARCHAR(20) NOT NULL DEFAULT 'BORROWER',
    created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE loans (
    id                  BIGSERIAL PRIMARY KEY,
    user_id             BIGINT NOT NULL REFERENCES users(id),
    loan_number         VARCHAR(50) NOT NULL UNIQUE,
    principal_amount    NUMERIC(15,2) NOT NULL,
    interest_rate       NUMERIC(6,4) NOT NULL,   -- e.g. 0.0525 = 5.25%
    term_months         INT NOT NULL,
    start_date          DATE NOT NULL,
    end_date            DATE NOT NULL,
    loan_type           VARCHAR(50) NOT NULL,     -- PERSONAL, AUTO, MORTGAGE, STUDENT
    status              VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    monthly_payment     NUMERIC(15,2) NOT NULL,
    outstanding_balance NUMERIC(15,2) NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE payment_schedule (
    id                  BIGSERIAL PRIMARY KEY,
    loan_id             BIGINT NOT NULL REFERENCES loans(id),
    payment_number      INT NOT NULL,
    due_date            DATE NOT NULL,
    scheduled_amount    NUMERIC(15,2) NOT NULL,
    principal_portion   NUMERIC(15,2) NOT NULL,
    interest_portion    NUMERIC(15,2) NOT NULL,
    beginning_balance   NUMERIC(15,2) NOT NULL,
    ending_balance      NUMERIC(15,2) NOT NULL,
    status              VARCHAR(20) NOT NULL DEFAULT 'PENDING',   -- PENDING, PAID, OVERDUE, SKIPPED
    created_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE payments (
    id                  BIGSERIAL PRIMARY KEY,
    loan_id             BIGINT NOT NULL REFERENCES loans(id),
    schedule_id         BIGINT REFERENCES payment_schedule(id),
    amount              NUMERIC(15,2) NOT NULL,
    payment_date        DATE NOT NULL,
    payment_method      VARCHAR(50) NOT NULL,    -- ACH, DEBIT_CARD, CHECK, ONLINE
    confirmation_number VARCHAR(100) UNIQUE,
    note                TEXT,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_loans_user_id ON loans(user_id);
CREATE INDEX idx_loans_status ON loans(status);
CREATE INDEX idx_payment_schedule_loan_id ON payment_schedule(loan_id);
CREATE INDEX idx_payment_schedule_due_date ON payment_schedule(due_date);
CREATE INDEX idx_payments_loan_id ON payments(loan_id);
CREATE INDEX idx_payments_payment_date ON payments(payment_date);
