// src/types/index.ts

export interface User {
  userId: number;
  email: string;
  firstName: string;
  lastName: string;
  token: string;
  tokenType: string;
}

export type LoanType = 'PERSONAL' | 'AUTO' | 'MORTGAGE' | 'STUDENT';
export type LoanStatus = 'ACTIVE' | 'PAID_OFF' | 'DEFAULTED' | 'DEFERRED';
export type ScheduleStatus = 'PENDING' | 'PAID' | 'OVERDUE' | 'SKIPPED';
export type PaymentMethod = 'ACH' | 'DEBIT_CARD' | 'CHECK' | 'ONLINE';

export interface LoanSummary {
  id: number;
  loanNumber: string;
  loanType: LoanType;
  status: LoanStatus;
  outstandingBalance: number;
  monthlyPayment: number;
  endDate: string;
}

export interface Loan {
  id: number;
  loanNumber: string;
  principalAmount: number;
  interestRate: number;
  termMonths: number;
  startDate: string;
  endDate: string;
  loanType: LoanType;
  status: LoanStatus;
  monthlyPayment: number;
  outstandingBalance: number;
  createdAt: string;
}

export interface ScheduleEntry {
  id: number;
  paymentNumber: number;
  dueDate: string;
  scheduledAmount: number;
  principalPortion: number;
  interestPortion: number;
  beginningBalance: number;
  endingBalance: number;
  status: ScheduleStatus;
}

export interface Payment {
  id: number;
  loanId: number;
  amount: number;
  paymentDate: string;
  paymentMethod: PaymentMethod;
  confirmationNumber: string;
  note?: string;
  createdAt: string;
}

export interface ForecastEntry {
  dueDate: string;
  loanNumber: string;
  loanType: LoanType;
  amount: number;
  status: ScheduleStatus;
}

export interface ForecastResponse {
  entries: ForecastEntry[];
  totalDue: number;
  months: number;
  from: string;
  to: string;
}

export interface CreateLoanRequest {
  principalAmount: number;
  interestRate: number;
  termMonths: number;
  startDate: string;
  loanType: LoanType;
}

export interface MakePaymentRequest {
  amount: number;
  paymentMethod: PaymentMethod;
  scheduleId?: number;
  note?: string;
}

export interface ApiError {
  title: string;
  detail: string;
  status: number;
}
