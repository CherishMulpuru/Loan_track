// src/components/dashboard/DashboardPage.tsx
import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from '../../hooks/useAuth';
import { loansApi, forecastApi } from '../../services/api';
import type { LoanSummary, ForecastResponse } from '../../types';
import { format } from 'date-fns';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts';

const USD = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' });

export default function DashboardPage() {
  const { user, logout } = useAuth();
  const [loans, setLoans] = useState<LoanSummary[]>([]);
  const [forecast, setForecast] = useState<ForecastResponse | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([loansApi.getAll(), forecastApi.get(6)])
      .then(([l, f]) => { setLoans(l); setForecast(f); })
      .finally(() => setLoading(false));
  }, []);

  const totalBalance = loans.reduce((s, l) => s + l.outstandingBalance, 0);
  const activeLoans = loans.filter(l => l.status === 'ACTIVE').length;

  const chartData = forecast?.entries.reduce((acc: Record<string, number>, e) => {
    const month = format(new Date(e.dueDate), 'MMM yy');
    acc[month] = (acc[month] || 0) + e.amount;
    return acc;
  }, {});

  const barData = chartData
    ? Object.entries(chartData).map(([month, amount]) => ({ month, amount }))
    : [];

  if (loading) return (
    <div className="min-h-screen flex items-center justify-center text-indigo-600 font-medium">
      Loading your loans...
    </div>
  );

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Nav */}
      <nav className="bg-white shadow-sm px-6 py-4 flex justify-between items-center">
        <h1 className="text-xl font-bold text-indigo-700">LoanTrack</h1>
        <div className="flex items-center gap-4">
          <span className="text-sm text-gray-600">
            Welcome, {user?.firstName}
          </span>
          <button onClick={logout} className="text-sm text-red-500 hover:underline">
            Sign Out
          </button>
        </div>
      </nav>

      <div className="max-w-6xl mx-auto p-6 space-y-6">
        {/* Summary Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <StatCard label="Total Outstanding" value={USD.format(totalBalance)} color="indigo" />
          <StatCard label="Active Loans" value={String(activeLoans)} color="green" />
          <StatCard
            label="Due Next 6 Months"
            value={forecast ? USD.format(forecast.totalDue) : '—'}
            color="amber"
          />
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Loans List */}
          <div className="bg-white rounded-xl shadow-sm p-6">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-lg font-semibold text-gray-800">My Loans</h2>
              <Link
                to="/loans/new"
                className="bg-indigo-600 hover:bg-indigo-700 text-white text-sm font-medium px-4 py-1.5 rounded-lg transition"
              >
                + New Loan
              </Link>
            </div>
            {loans.length === 0 ? (
              <p className="text-gray-400 text-sm text-center py-8">No loans yet. Create your first loan!</p>
            ) : (
              <div className="space-y-3">
                {loans.map(loan => (
                  <Link
                    key={loan.id}
                    to={`/loans/${loan.id}`}
                    className="block border border-gray-100 rounded-lg p-4 hover:border-indigo-300 hover:shadow-sm transition"
                  >
                    <div className="flex justify-between items-start">
                      <div>
                        <p className="font-medium text-gray-800">{loan.loanNumber}</p>
                        <p className="text-xs text-gray-500">{loan.loanType} • {loan.status}</p>
                      </div>
                      <div className="text-right">
                        <p className="font-semibold text-indigo-700">{USD.format(loan.outstandingBalance)}</p>
                        <p className="text-xs text-gray-500">{USD.format(loan.monthlyPayment)}/mo</p>
                      </div>
                    </div>
                  </Link>
                ))}
              </div>
            )}
          </div>

          {/* Payment Forecast Chart */}
          <div className="bg-white rounded-xl shadow-sm p-6">
            <h2 className="text-lg font-semibold text-gray-800 mb-4">6-Month Payment Forecast</h2>
            {barData.length > 0 ? (
              <ResponsiveContainer width="100%" height={220}>
                <BarChart data={barData}>
                  <XAxis dataKey="month" tick={{ fontSize: 12 }} />
                  <YAxis tickFormatter={v => `$${(v/1000).toFixed(0)}k`} tick={{ fontSize: 12 }} />
                  <Tooltip formatter={(v: number) => USD.format(v)} />
                  <Bar dataKey="amount" fill="#6366f1" radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            ) : (
              <p className="text-gray-400 text-sm text-center py-16">No upcoming payments</p>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

function StatCard({ label, value, color }: { label: string; value: string; color: string }) {
  const colors: Record<string, string> = {
    indigo: 'bg-indigo-50 border-indigo-200 text-indigo-700',
    green: 'bg-green-50 border-green-200 text-green-700',
    amber: 'bg-amber-50 border-amber-200 text-amber-700',
  };
  return (
    <div className={`border rounded-xl p-5 ${colors[color]}`}>
      <p className="text-sm font-medium opacity-70">{label}</p>
      <p className="text-3xl font-bold mt-1">{value}</p>
    </div>
  );
}
