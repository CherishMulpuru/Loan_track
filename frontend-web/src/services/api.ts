// src/services/api.ts
import axios, { AxiosInstance, AxiosError } from 'axios';
import type {
  User, Loan, LoanSummary, ScheduleEntry, Payment,
  ForecastResponse, CreateLoanRequest, MakePaymentRequest
} from '../types';

const BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8080/api/v1';

const apiClient: AxiosInstance = axios.create({
  baseURL: BASE_URL,
  headers: { 'Content-Type': 'application/json' },
});

// Attach JWT on every request
apiClient.interceptors.request.use((config) => {
  const token = localStorage.getItem('lt_token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

// Redirect to login on 401
apiClient.interceptors.response.use(
  (res) => res,
  (err: AxiosError) => {
    if (err.response?.status === 401) {
      localStorage.removeItem('lt_token');
      window.location.href = '/login';
    }
    return Promise.reject(err);
  }
);

// ─── Auth ─────────────────────────────────────────────────────────────────────

export const authApi = {
  register: async (data: {
    email: string; password: string;
    firstName: string; lastName: string; phone?: string;
  }): Promise<User> => {
    const res = await apiClient.post<User>('/auth/register', data);
    return res.data;
  },

  login: async (email: string, password: string): Promise<User> => {
    const res = await apiClient.post<User>('/auth/login', { email, password });
    return res.data;
  },
};

// ─── Loans ────────────────────────────────────────────────────────────────────

export const loansApi = {
  getAll: async (): Promise<LoanSummary[]> => {
    const res = await apiClient.get<LoanSummary[]>('/loans');
    return res.data;
  },

  getById: async (id: number): Promise<Loan> => {
    const res = await apiClient.get<Loan>(`/loans/${id}`);
    return res.data;
  },

  create: async (data: CreateLoanRequest): Promise<Loan> => {
    const res = await apiClient.post<Loan>('/loans', data);
    return res.data;
  },
};

// ─── Payments ─────────────────────────────────────────────────────────────────

export const paymentsApi = {
  getHistory: async (loanId: number): Promise<Payment[]> => {
    const res = await apiClient.get<Payment[]>(`/loans/${loanId}/payments`);
    return res.data;
  },

  makePayment: async (loanId: number, data: MakePaymentRequest): Promise<Payment> => {
    const res = await apiClient.post<Payment>(`/loans/${loanId}/payments`, data);
    return res.data;
  },

  getSchedule: async (loanId: number): Promise<ScheduleEntry[]> => {
    const res = await apiClient.get<ScheduleEntry[]>(`/loans/${loanId}/schedule`);
    return res.data;
  },
};

// ─── Forecast ─────────────────────────────────────────────────────────────────

export const forecastApi = {
  get: async (months = 6): Promise<ForecastResponse> => {
    const res = await apiClient.get<ForecastResponse>(`/forecast?months=${months}`);
    return res.data;
  },
};

export default apiClient;
