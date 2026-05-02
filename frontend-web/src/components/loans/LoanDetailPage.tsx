// src/components/loans/LoanDetailPage.tsx
import React, { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { loansApi, paymentsApi } from '../../services/api';
import type { Loan, ScheduleEntry, Payment } from '../../types';
import { format } from 'date-fns';

const USD = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' });
const PCT = new Intl.NumberFormat('en-US', { style: 'percent', minimumFractionDigits: 2 });

export default function LoanDetailPage() {
  const { id } = useParams<{ id: string }>();
  const loanId = Number(id);

  const [loan, setLoan] = useState<Loan | null>(null);
  const [schedule, setSchedule] = useState<ScheduleEntry[]>([]);
  const [payments, setPayments] = useState<Payment[]>([]);
  const [tab, setTab] = useState<'schedule' | 'payments'>('schedule');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([
      loansApi.getById(loanId),
      paymentsApi.getSchedule(loanId),
      paymentsApi.getHistory(loanId),
    ]).then(([l, s, p]) => {
      setLoan(l); setSchedule(s); setPayments(p);
    }).finally(() => setLoading(false));
  }, [loanId]);

  if (loading) return <div className="p-8 text-center text-indigo-600">Loading loan details...</div>;
  if (!loan) return <div className="p-8 text-center text-red-500">Loan not found.</div>;

  const paidCount = schedule.filter(s => s.status === 'PAID').length;
  const progress = Math.round((paidCount / loan.termMonths) * 100);

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow-sm px-6 py-4">
        <Link to="/dashboard" className="text-indigo-600 hover:underline text-sm">← Dashboard</Link>
      </nav>

      <div className="max-w-5xl mx-auto p-6 space-y-6">
        {/* Loan Header */}
        <div className="bg-white rounded-xl shadow-sm p-6">
          <div className="flex justify-between items-start flex-wrap gap-4">
            <div>
              <h1 className="text-2xl font-bold text-gray-800">{loan.loanNumber}</h1>
              <p className="text-gray-500 text-sm mt-1">
                {loan.loanType} • {loan.status} • {loan.termMonths} months
              </p>
            </div>
            <Link
              to={`/loans/${loan.id}/pay`}
              className="bg-indigo-600 hover:bg-indigo-700 text-white font-semibold px-5 py-2 rounded-lg transition"
            >
              Make Payment
            </Link>
          </div>

          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-6">
            <InfoItem label="Principal" value={USD.format(loan.principalAmount)} />
            <InfoItem label="Rate" value={PCT.format(loan.interestRate)} />
            <InfoItem label="Monthly" value={USD.format(loan.monthlyPayment)} />
            <InfoItem label="Outstanding" value={USD.format(loan.outstandingBalance)} highlight />
          </div>

          {/* Progress Bar */}
          <div className="mt-4">
            <div className="flex justify-between text-xs text-gray-500 mb-1">
              <span>{paidCount} of {loan.termMonths} payments made</span>
              <span>{progress}%</span>
            </div>
            <div className="h-2 bg-gray-100 rounded-full overflow-hidden">
              <div
                className="h-full bg-indigo-500 rounded-full transition-all"
                style={{ width: `${progress}%` }}
              />
            </div>
          </div>
        </div>

        {/* Tabs */}
        <div className="bg-white rounded-xl shadow-sm overflow-hidden">
          <div className="flex border-b">
            {(['schedule', 'payments'] as const).map(t => (
              <button
                key={t}
                onClick={() => setTab(t)}
                className={`px-6 py-3 text-sm font-medium transition ${
                  tab === t
                    ? 'border-b-2 border-indigo-600 text-indigo-600'
                    : 'text-gray-500 hover:text-gray-700'
                }`}
              >
                {t === 'schedule' ? 'Amortization Schedule' : 'Payment History'}
              </button>
            ))}
          </div>

          <div className="overflow-x-auto p-4">
            {tab === 'schedule' ? (
              <table className="w-full text-sm">
                <thead>
                  <tr className="text-left text-gray-500 border-b text-xs uppercase">
                    <th className="pb-2 pr-4">#</th>
                    <th className="pb-2 pr-4">Due Date</th>
                    <th className="pb-2 pr-4">Payment</th>
                    <th className="pb-2 pr-4">Principal</th>
                    <th className="pb-2 pr-4">Interest</th>
                    <th className="pb-2 pr-4">Balance</th>
                    <th className="pb-2">Status</th>
                  </tr>
                </thead>
                <tbody>
                  {schedule.map(row => (
                    <tr key={row.id} className="border-b border-gray-50 hover:bg-gray-50">
                      <td className="py-2 pr-4 text-gray-400">{row.paymentNumber}</td>
                      <td className="py-2 pr-4">{format(new Date(row.dueDate), 'MMM d, yyyy')}</td>
                      <td className="py-2 pr-4 font-medium">{USD.format(row.scheduledAmount)}</td>
                      <td className="py-2 pr-4 text-green-600">{USD.format(row.principalPortion)}</td>
                      <td className="py-2 pr-4 text-orange-500">{USD.format(row.interestPortion)}</td>
                      <td className="py-2 pr-4">{USD.format(row.endingBalance)}</td>
                      <td className="py-2">
                        <StatusBadge status={row.status} />
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            ) : (
              payments.length === 0 ? (
                <p className="text-center text-gray-400 py-8">No payments recorded yet.</p>
              ) : (
                <table className="w-full text-sm">
                  <thead>
                    <tr className="text-left text-gray-500 border-b text-xs uppercase">
                      <th className="pb-2 pr-4">Date</th>
                      <th className="pb-2 pr-4">Amount</th>
                      <th className="pb-2 pr-4">Method</th>
                      <th className="pb-2">Confirmation #</th>
                    </tr>
                  </thead>
                  <tbody>
                    {payments.map(p => (
                      <tr key={p.id} className="border-b border-gray-50 hover:bg-gray-50">
                        <td className="py-2 pr-4">{format(new Date(p.paymentDate), 'MMM d, yyyy')}</td>
                        <td className="py-2 pr-4 font-semibold text-green-600">{USD.format(p.amount)}</td>
                        <td className="py-2 pr-4">{p.paymentMethod.replace('_', ' ')}</td>
                        <td className="py-2 font-mono text-xs text-gray-500">{p.confirmationNumber}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              )
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

function InfoItem({ label, value, highlight }: { label: string; value: string; highlight?: boolean }) {
  return (
    <div className="bg-gray-50 rounded-lg p-3">
      <p className="text-xs text-gray-500">{label}</p>
      <p className={`text-lg font-semibold mt-0.5 ${highlight ? 'text-indigo-700' : 'text-gray-800'}`}>
        {value}
      </p>
    </div>
  );
}

function StatusBadge({ status }: { status: string }) {
  const styles: Record<string, string> = {
    PENDING: 'bg-yellow-100 text-yellow-700',
    PAID: 'bg-green-100 text-green-700',
    OVERDUE: 'bg-red-100 text-red-700',
    SKIPPED: 'bg-gray-100 text-gray-500',
  };
  return (
    <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${styles[status] || styles.PENDING}`}>
      {status}
    </span>
  );
}
