// src/components/payments/MakePaymentPage.tsx
import React, { useState, useEffect } from 'react';
import { useParams, useNavigate, Link } from 'react-router-dom';
import { loansApi, paymentsApi } from '../../services/api';
import type { Loan, ScheduleEntry, PaymentMethod } from '../../types';

const METHODS: PaymentMethod[] = ['ACH', 'DEBIT_CARD', 'CHECK', 'ONLINE'];

export default function MakePaymentPage() {
  const { id } = useParams<{ id: string }>();
  const loanId = Number(id);
  const navigate = useNavigate();

  const [loan, setLoan] = useState<Loan | null>(null);
  const [pending, setPending] = useState<ScheduleEntry[]>([]);
  const [amount, setAmount] = useState('');
  const [method, setMethod] = useState<PaymentMethod>('ACH');
  const [scheduleId, setScheduleId] = useState<number | undefined>();
  const [note, setNote] = useState('');
  const [success, setSuccess] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    loansApi.getById(loanId).then(l => {
      setLoan(l);
      setAmount(String(l.monthlyPayment));
    });
    paymentsApi.getSchedule(loanId).then(s =>
      setPending(s.filter(e => e.status === 'PENDING').slice(0, 3))
    );
  }, [loanId]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(''); setSuccess('');
    setLoading(true);
    try {
      const p = await paymentsApi.makePayment(loanId, {
        amount: Number(amount),
        paymentMethod: method,
        scheduleId,
        note: note || undefined,
      });
      setSuccess(`Payment confirmed! Confirmation #: ${p.confirmationNumber}`);
      setTimeout(() => navigate(`/loans/${loanId}`), 2500);
    } catch (err: any) {
      setError(err.response?.data?.detail || 'Payment failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow-sm px-6 py-4">
        <Link to={`/loans/${loanId}`} className="text-indigo-600 hover:underline text-sm">
          ← Back to Loan
        </Link>
      </nav>

      <div className="max-w-lg mx-auto p-6">
        <div className="bg-white rounded-xl shadow-sm p-8">
          <h1 className="text-2xl font-bold text-gray-800 mb-2">Make a Payment</h1>
          {loan && (
            <p className="text-sm text-gray-500 mb-6">
              {loan.loanNumber} — Balance:{' '}
              <span className="font-medium text-indigo-700">
                ${loan.outstandingBalance.toLocaleString()}
              </span>
            </p>
          )}

          {success && (
            <div className="bg-green-50 border border-green-200 text-green-700 rounded-lg p-4 mb-4 text-sm font-medium">
              ✓ {success}
            </div>
          )}
          {error && (
            <div className="bg-red-50 border border-red-200 text-red-700 rounded-lg p-3 mb-4 text-sm">{error}</div>
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            {pending.length > 0 && (
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Apply to Schedule Entry (optional)
                </label>
                <select
                  value={scheduleId || ''}
                  onChange={e => setScheduleId(e.target.value ? Number(e.target.value) : undefined)}
                  className="input-s"
                >
                  <option value="">— None —</option>
                  {pending.map(p => (
                    <option key={p.id} value={p.id}>
                      Payment #{p.paymentNumber} — Due {p.dueDate} — ${p.scheduledAmount}
                    </option>
                  ))}
                </select>
              </div>
            )}

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Amount ($)</label>
              <input
                type="number" min="0.01" step="0.01" required value={amount}
                onChange={e => setAmount(e.target.value)}
                className="input-s"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Payment Method</label>
              <select value={method} onChange={e => setMethod(e.target.value as PaymentMethod)} className="input-s">
                {METHODS.map(m => <option key={m} value={m}>{m.replace('_', ' ')}</option>)}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Note (optional)</label>
              <input type="text" value={note} onChange={e => setNote(e.target.value)}
                className="input-s" placeholder="e.g. Extra principal payment" />
            </div>

            <button
              type="submit" disabled={loading || !!success}
              className="w-full bg-green-600 hover:bg-green-700 disabled:opacity-50 text-white font-semibold rounded-lg py-2.5 transition"
            >
              {loading ? 'Processing...' : 'Submit Payment'}
            </button>
          </form>
        </div>
      </div>
      <style>{`.input-s{width:100%;border:1px solid #d1d5db;border-radius:.5rem;padding:.5rem 1rem;outline:none}.input-s:focus{box-shadow:0 0 0 2px #6366f1}`}</style>
    </div>
  );
}
