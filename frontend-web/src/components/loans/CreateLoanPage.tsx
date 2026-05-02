// src/components/loans/CreateLoanPage.tsx
import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { loansApi } from '../../services/api';
import type { LoanType } from '../../types';

const LOAN_TYPES: LoanType[] = ['PERSONAL', 'AUTO', 'MORTGAGE', 'STUDENT'];

export default function CreateLoanPage() {
  const navigate = useNavigate();
  const [form, setForm] = useState({
    principalAmount: '',
    interestRate: '',
    termMonths: '',
    startDate: new Date().toISOString().split('T')[0],
    loanType: 'PERSONAL' as LoanType,
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const set = (field: string) => (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) =>
    setForm(f => ({ ...f, [field]: e.target.value }));

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const loan = await loansApi.create({
        principalAmount: Number(form.principalAmount),
        interestRate: Number(form.interestRate) / 100,  // convert % to decimal
        termMonths: Number(form.termMonths),
        startDate: form.startDate,
        loanType: form.loanType,
      });
      navigate(`/loans/${loan.id}`);
    } catch (err: any) {
      setError(err.response?.data?.detail || 'Failed to create loan.');
    } finally {
      setLoading(false);
    }
  };

  const estMonthly = (() => {
    const P = Number(form.principalAmount);
    const r = Number(form.interestRate) / 100 / 12;
    const n = Number(form.termMonths);
    if (!P || !n) return null;
    if (!r) return (P / n).toFixed(2);
    return (P * (r * Math.pow(1 + r, n)) / (Math.pow(1 + r, n) - 1)).toFixed(2);
  })();

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow-sm px-6 py-4">
        <Link to="/dashboard" className="text-indigo-600 hover:underline text-sm">← Dashboard</Link>
      </nav>

      <div className="max-w-lg mx-auto p-6">
        <div className="bg-white rounded-xl shadow-sm p-8">
          <h1 className="text-2xl font-bold text-gray-800 mb-6">Create New Loan</h1>

          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 rounded-lg p-3 mb-4 text-sm">{error}</div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <Field label="Loan Type">
              <select value={form.loanType} onChange={set('loanType')} className="input-style">
                {LOAN_TYPES.map(t => <option key={t} value={t}>{t}</option>)}
              </select>
            </Field>

            <Field label="Principal Amount ($)">
              <input type="number" min="1000" step="100" required value={form.principalAmount}
                onChange={set('principalAmount')} className="input-style" placeholder="10000" />
            </Field>

            <Field label="Annual Interest Rate (%)">
              <input type="number" min="0.01" max="100" step="0.01" required value={form.interestRate}
                onChange={set('interestRate')} className="input-style" placeholder="5.25" />
            </Field>

            <Field label="Term (months)">
              <input type="number" min="1" max="360" required value={form.termMonths}
                onChange={set('termMonths')} className="input-style" placeholder="36" />
            </Field>

            <Field label="Start Date">
              <input type="date" required value={form.startDate}
                onChange={set('startDate')} className="input-style" />
            </Field>

            {estMonthly && (
              <div className="bg-indigo-50 border border-indigo-200 rounded-lg p-4 text-center">
                <p className="text-sm text-indigo-600">Estimated Monthly Payment</p>
                <p className="text-2xl font-bold text-indigo-700">
                  ${Number(estMonthly).toLocaleString('en-US', { minimumFractionDigits: 2 })}
                </p>
              </div>
            )}

            <button
              type="submit" disabled={loading}
              className="w-full bg-indigo-600 hover:bg-indigo-700 disabled:opacity-50 text-white font-semibold rounded-lg py-2.5 transition"
            >
              {loading ? 'Creating...' : 'Create Loan & Generate Schedule'}
            </button>
          </form>
        </div>
      </div>

      <style>{`
        .input-style {
          width: 100%;
          border: 1px solid #d1d5db;
          border-radius: 0.5rem;
          padding: 0.5rem 1rem;
          outline: none;
          transition: box-shadow 0.15s;
        }
        .input-style:focus {
          box-shadow: 0 0 0 2px #6366f1;
        }
      `}</style>
    </div>
  );
}

function Field({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div>
      <label className="block text-sm font-medium text-gray-700 mb-1">{label}</label>
      {children}
    </div>
  );
}
