// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/loan.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<LoanSummary>? _loans;
  ForecastResponse? _forecast;
  bool _loading = true;
  String? _error;

  final _usd = NumberFormat.currency(locale: 'en_US', symbol: '\$');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final loans = await apiService.getLoans();
      final forecast = await apiService.getForecast();
      if (mounted) setState(() { _loans = loans; _forecast = forecast; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Failed to load data.'; _loading = false; });
    }
  }

  Future<void> _logout() async {
    await apiService.logout();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('LoanTrack', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/loans/new'),
        icon: const Icon(Icons.add),
        label: const Text('New Loan'),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
          ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Summary cards
                  Row(children: [
                    _SummaryCard(
                      label: 'Total Balance',
                      value: _usd.format(_loans!.fold(0.0, (s, l) => s + l.outstandingBalance)),
                      color: cs.primary,
                    ),
                    const SizedBox(width: 12),
                    _SummaryCard(
                      label: 'Due (6mo)',
                      value: _forecast != null ? _usd.format(_forecast!.totalDue) : '—',
                      color: Colors.amber.shade700,
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // Forecast section
                  if (_forecast != null && _forecast!.entries.isNotEmpty) ...[
                    Text('Upcoming Payments',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
                          color: cs.onSurface)),
                    const SizedBox(height: 12),
                    ..._forecast!.entries.take(5).map((e) => _ForecastTile(entry: e, usd: _usd)),
                    const SizedBox(height: 24),
                  ],

                  // Loans section
                  Text('My Loans',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface)),
                  const SizedBox(height: 12),
                  if (_loans!.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No loans yet. Tap + to create one.',
                          style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else
                    ..._loans!.map((loan) => _LoanCard(loan: loan, usd: _usd)),
                ],
              ),
            ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ]),
    ),
  );
}

class _LoanCard extends StatelessWidget {
  final LoanSummary loan;
  final NumberFormat usd;

  const _LoanCard({required this.loan, required this.usd});

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      onTap: () => context.go('/loans/${loan.id}'),
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(_loanIcon(loan.loanType),
          color: Theme.of(context).colorScheme.primary),
      ),
      title: Text(loan.loanNumber, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('${loan.loanType} • ${loan.status}'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(usd.format(loan.outstandingBalance),
            style: TextStyle(fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary)),
          Text('${usd.format(loan.monthlyPayment)}/mo',
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    ),
  );

  IconData _loanIcon(String type) {
    switch (type) {
      case 'AUTO': return Icons.directions_car;
      case 'MORTGAGE': return Icons.home;
      case 'STUDENT': return Icons.school;
      default: return Icons.person;
    }
  }
}

class _ForecastTile extends StatelessWidget {
  final ForecastEntry entry;
  final NumberFormat usd;

  const _ForecastTile({required this.entry, required this.usd});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(entry.dueDate);
    return ListTile(
      dense: true,
      leading: Container(
        width: 48, height: 48,
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(DateFormat('MMM').format(date),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber)),
          Text(DateFormat('d').format(date),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
      ),
      title: Text(entry.loanNumber),
      subtitle: Text(entry.loanType),
      trailing: Text(usd.format(entry.amount),
        style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
