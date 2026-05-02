# LoanTrack — Full-Stack Lending Experience Platform

A production-grade borrower loan management platform built across four layers:
**Flutter/Dart mobile**, **TypeScript React web**, **Spring Boot REST API**, and **PostgreSQL on AWS**.

Borrowers can track loan schedules, view amortization tables, make payments, and see payment forecasts — secured with JWT auth and documented with OpenAPI contracts.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                             │
│                                                                 │
│   Flutter/Dart Mobile (iOS + Android)   React/TS Web (Vite)    │
│           ↕  JWT Bearer Token                 ↕                │
└─────────────────────────────────────────────────────────────────┘
                              ↕ HTTPS
┌─────────────────────────────────────────────────────────────────┐
│                       API LAYER (AWS ECS)                       │
│                                                                 │
│          Spring Boot 3.2 + Java 17 REST API                    │
│    /auth  /loans  /loans/{id}/payments  /forecast               │
│                                                                 │
│    JWT Filter → Security → Controllers → Services               │
│                              ↕                                  │
│              Flyway Migrations + JPA/Hibernate                  │
└─────────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────────┐
│                    DATA LAYER (AWS RDS)                         │
│                                                                 │
│   PostgreSQL 15  —  users · loans · payment_schedule · payments │
└─────────────────────────────────────────────────────────────────┘
```

---

## Project Structure

```
loantrack/
├── backend/                          # Spring Boot REST API
│   ├── src/main/java/com/loantrack/
│   │   ├── config/                   # Security, OpenAPI, GlobalExceptionHandler
│   │   ├── controller/               # AuthController, LoanController,
│   │   │                             #   PaymentController, ForecastController
│   │   ├── dto/                      # Request/Response DTOs
│   │   ├── entity/                   # User, Loan, PaymentSchedule, Payment
│   │   ├── repository/               # Spring Data JPA repositories
│   │   ├── security/                 # JwtService, JwtAuthenticationFilter
│   │   └── service/                  # AmortizationService, AuthService,
│   │                                 #   LoanService, PaymentService, ForecastService
│   ├── src/main/resources/
│   │   ├── application.yml
│   │   └── db/migration/             # Flyway SQL migrations
│   ├── src/test/                     # JUnit 5 unit + integration tests
│   ├── Dockerfile
│   └── pom.xml
│
├── frontend-web/                     # React + TypeScript web app
│   ├── src/
│   │   ├── components/
│   │   │   ├── auth/                 # LoginPage
│   │   │   ├── dashboard/            # DashboardPage (charts, loan list)
│   │   │   ├── loans/                # LoanDetailPage, CreateLoanPage
│   │   │   └── payments/             # MakePaymentPage
│   │   ├── hooks/                    # useAuth (AuthContext)
│   │   ├── services/                 # api.ts (axios client)
│   │   └── types/                    # TypeScript interfaces
│   ├── index.html
│   ├── vite.config.ts
│   └── package.json
│
├── mobile/                           # Flutter/Dart mobile app
│   ├── lib/
│   │   ├── main.dart                 # App entry + GoRouter
│   │   ├── models/                   # Dart data models
│   │   ├── screens/                  # LoginScreen, DashboardScreen,
│   │   │                             #   LoanDetailScreen, PaymentScreen
│   │   └── services/                 # ApiService (Dio + FlutterSecureStorage)
│   ├── test/                         # Widget tests
│   └── pubspec.yaml
│
├── .github/workflows/
│   └── ci-cd.yml                     # GitHub Actions: test → build → deploy
├── docker-compose.yml                # Local full-stack dev environment
├── .env.example
└── README.md
```

---

## Prerequisites

| Tool | Version |
|------|---------|
| Java | 17+ |
| Maven | 3.9+ |
| Node.js | 20+ |
| Flutter | 3.16+ |
| Docker + Docker Compose | Latest |
| PostgreSQL | 15 (or use Docker) |

---

## Quick Start — Local Dev (Recommended: Docker Compose)

**1. Clone and configure**
```bash
git clone https://github.com/your-org/loantrack.git
cd loantrack
cp .env.example .env
# Edit .env with your secrets if needed
```

**2. Start everything with Docker Compose**
```bash
docker-compose up --build
```

This starts:
- PostgreSQL on port `5432`
- Spring Boot API on port `8080`
- React web app on port `3000`

**3. Open the web app**
```
http://localhost:3000
```

**4. View the API docs (Swagger UI)**
```
http://localhost:8080/swagger-ui.html
```

---

## Manual Setup (Without Docker)

### Backend (Spring Boot)

```bash
# 1. Create PostgreSQL database
psql -U postgres -c "CREATE DATABASE loantrack;"
psql -U postgres -c "CREATE USER loantrack WITH PASSWORD 'loantrack';"
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE loantrack TO loantrack;"

# 2. Set environment variables
export DB_URL=jdbc:postgresql://localhost:5432/loantrack
export DB_USERNAME=loantrack
export DB_PASSWORD=loantrack
export JWT_SECRET=your-at-least-32-character-secret-key-here

# 3. Build and run
cd backend
mvn spring-boot:run
```

### Web Frontend (React + TypeScript)

```bash
cd frontend-web
npm install
npm run dev
# Open http://localhost:3000
```

### Mobile (Flutter)

```bash
cd mobile
flutter pub get

# iOS simulator
flutter run -d ios

# Android emulator (uses 10.0.2.2 to reach localhost)
flutter run -d android
```

---

## Running Tests

### Backend (JUnit 5)
```bash
cd backend
mvn test
```
Tests use H2 in-memory database (no PostgreSQL needed). Includes:
- `AmortizationServiceTest` — unit tests for payment calculation and schedule generation
- `AuthControllerIntegrationTest` — full-stack integration tests via MockMvc

### Web Frontend
```bash
cd frontend-web
npm run test
npm run lint
```

### Mobile (Flutter)
```bash
cd mobile
flutter test
flutter analyze
```

---

## API Reference

Full OpenAPI spec: `http://localhost:8080/api-docs`
Interactive UI: `http://localhost:8080/swagger-ui.html`

### Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/v1/auth/register` | Register a new borrower |
| `POST` | `/api/v1/auth/login` | Login → receive JWT |

All other endpoints require `Authorization: Bearer <token>`.

### Loans

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/v1/loans` | List all loans for authenticated user |
| `POST` | `/api/v1/loans` | Create loan (auto-generates amortization schedule) |
| `GET` | `/api/v1/loans/{id}` | Get loan details |

### Payments

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/v1/loans/{id}/payments` | Payment history |
| `POST` | `/api/v1/loans/{id}/payments` | Make a payment |
| `GET` | `/api/v1/loans/{id}/schedule` | Full amortization schedule |

### Forecast

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/v1/forecast?months=6` | Upcoming payments across all loans |

### Example: Create a Loan

```bash
curl -X POST http://localhost:8080/api/v1/loans \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "principalAmount": 15000.00,
    "interestRate": 0.0525,
    "termMonths": 60,
    "startDate": "2024-02-01",
    "loanType": "AUTO"
  }'
```

Response includes the calculated `monthlyPayment`, `loanNumber`, and complete loan details. A 60-entry amortization schedule is generated and stored automatically.

---

## Key Technical Decisions

### Amortization Engine
The `AmortizationService` implements the standard annuity formula:

```
M = P × [r(1+r)ⁿ] / [(1+r)ⁿ - 1]
```

where P = principal, r = monthly rate, n = term in months. Uses `BigDecimal` throughout for financial precision — never `double`.

### JWT Security
Tokens are signed with HMAC-SHA256, carry `userId` and `role` claims, and expire in 24 hours by default. The `JwtAuthenticationFilter` runs before every request. Tokens are stored in `FlutterSecureStorage` (mobile) and `localStorage` (web — swap for httpOnly cookies in high-security deployments).

### OpenAPI Contract-First Design
All endpoints are annotated with SpringDoc OpenAPI 3.1. The spec at `/api-docs` is the source of truth for frontend-backend contracts.

### Database Migrations
Flyway handles all schema changes via versioned SQL scripts in `db/migration/`. Never use `ddl-auto: create` in production — `validate` is used instead to catch drift.

---

## AWS Deployment

The CI/CD pipeline (`.github/workflows/ci-cd.yml`) deploys automatically on push to `main`:

1. **Backend** → Docker image pushed to ECR → deployed on ECS Fargate
2. **Web Frontend** → Vite build → synced to S3 → CloudFront cache invalidated
3. **Database** → AWS RDS PostgreSQL (managed, not in Docker)

Required GitHub Secrets:
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
CF_DISTRIBUTION_ID
JWT_SECRET          (set in ECS task definition)
DB_PASSWORD         (set in ECS task definition / Secrets Manager)
```

---

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DB_URL` | JDBC connection string | `jdbc:postgresql://localhost:5432/loantrack` |
| `DB_USERNAME` | DB username | `loantrack` |
| `DB_PASSWORD` | DB password | `loantrack` |
| `JWT_SECRET` | HMAC signing key (min 32 chars) | — |
| `JWT_EXPIRATION` | Token TTL in ms | `86400000` (24h) |
| `PORT` | Server port | `8080` |
| `VITE_API_URL` | Web app API base URL | `http://localhost:8080/api/v1` |

---

## Tech Stack Summary

| Layer | Technology |
|-------|------------|
| Mobile | Flutter 3.x / Dart, Dio, GoRouter, FlutterSecureStorage |
| Web | React 18, TypeScript, Vite, Axios, Recharts, React Query |
| API | Spring Boot 3.2, Java 17, Spring Security, JPA/Hibernate |
| Auth | JWT (jjwt), BCrypt password hashing |
| Docs | SpringDoc OpenAPI 3.1 / Swagger UI |
| Database | PostgreSQL 15, Flyway migrations |
| Testing | JUnit 5, MockMvc, H2 (backend); Vitest (web); Flutter Test (mobile) |
| CI/CD | GitHub Actions |
| Infrastructure | AWS ECS Fargate, RDS, S3, CloudFront, ECR |
| Containers | Docker, Docker Compose |

---
