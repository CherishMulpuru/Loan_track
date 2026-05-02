// lib/screens/loan_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/loan.dart';

class LoanDetailScreen extends StatefulWidget {
  final int loanId;
  const LoanDetailScreen({super.key, required this.loanId});

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen>
    with SingleTickerProviderStateMixin {
  Loan? _loan;
  List<ScheduleEntry>? _schedule;
  bool _loading = true;
  late TabController _tabs;
  final _usd = NumberFormat.currency(locale: 'en_US', symbol: '\$');
  final _pct = NumberFormat.percentPattern()..maximumFractionDigits = 2;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    try {
      final loan = await apiService.getLoan(widget.loanId);
      final schedule = await apiService.getSchedule(widget.loanId);
      if (mounted) setState(() { _loan = loan; _schedule = schedule; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(_loan?.loanNumber ?? 'Loan Details'),
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        leading: BackButton(onPressed: () => context.go('/dashboard')),
      ),
      floatingActionButton: _loan?.status == 'ACTIVE'
        ? FloatingActionButton.extended(
            onPressed: () => context.go('/loans/${widget.loanId}/pay'),
            icon: const Icon(Icons.payment),
            label: const Text('Make Payment'),
          )
        : null,
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _loan == null
          ? const Center(child: Text('Loan not found'))
          : Column(children: [
              // Header card
              Container(
                color: cs.primary.withOpacity(0.05),
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _InfoChip('Principal', _usd.format(_loan!.principalAmount)),
                      _InfoChip('Rate', '${(_loan!.interestRate * 100).toStringAsFixed(2)}%'),
                      _InfoChip('Term', '${_loan!.termMonths}mo'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _InfoChip('Monthly', _usd.format(_loan!.monthlyPayment)),
                      _InfoChip('Balance', _usd.format(_loan!.outstandingBalance), highlight: true),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress bar
                  Builder(builder: (ctx) {
                    final paid = _schedule?.where((s) => s.status == 'PAID').length ?? 0;
                    final progress = paid / _loan!.termMonths;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('$paid / ${_loan!.termMonths} payments',
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('${(progress * 100).toInt()}%',
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ]),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: cs.primary.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation(cs.primary),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                ]),
              ),
              // Tabs
              TabBar(
                controller: _tabs,
                tabs: const [Tab(text: 'Amortization'), Tab(text: 'Details')],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabs,
                  children: [
                    _ScheduleTab(schedule: _schedule ?? [], usd: _usd),
                    _DetailsTab(loan: _loan!, usd: _usd),
                  ],
                ),
              ),
            ]),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _InfoChip(this.label, this.value, {this.highlight = false});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      Text(value, style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: highlight ? 18 : 15,
        color: highlight ? Theme.of(context).colorScheme.primary : null,
      )),
    ],
  );
}

class _ScheduleTab extends StatelessWidget {
  final List<ScheduleEntry> schedule;
  final NumberFormat usd;

  const _ScheduleTab({required this.schedule, required this.usd});

  Color _statusColor(String status) {
    switch (status) {
      case 'PAID': return Colors.green;
      case 'OVERDUE': return Colors.red;
      case 'PENDING': return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: schedule.length,
      itemBuilder: (ctx, i) {
        final e = schedule[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              SizedBox(
                width: 28,
                child: Text('${e.paymentNumber}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.dueDate, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                  const SizedBox(height: 2),
                  Row(children: [
                    Text('P: ${usd.format(e.principalPortion)}',
                      style: const TextStyle(fontSize: 11, color: Colors.green)),
                    const SizedBox(width: 8),
                    Text('I: ${usd.format(e.interestPortion)}',
                      style: const TextStyle(fontSize: 11, color: Colors.orange)),
                  ]),
                ],
              )),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(usd.format(e.scheduledAmount),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: _statusColor(e.status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(e.status,
                    style: TextStyle(fontSize: 10, color: _statusColor(e.status),
                        fontWeight: FontWeight.bold)),
                ),
              ]),
            ]),
          ),
        );
      },
    );
  }
}

class _DetailsTab extends StatelessWidget {
  final Loan loan;
  final NumberFormat usd;

  const _DetailsTab({required this.loan, required this.usd});

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      _DetailRow('Loan Number', loan.loanNumber),
      _DetailRow('Type', loan.loanType),
      _DetailRow('Status', loan.status),
      _DetailRow('Start Date', loan.startDate),
      _DetailRow('End Date', loan.endDate),
      _DetailRow('Principal', usd.format(loan.principalAmount)),
      _DetailRow('Interest Rate', '${(loan.interestRate * 100).toStringAsFixed(3)}%'),
      _DetailRow('Term', '${loan.termMonths} months'),
      _DetailRow('Monthly Payment', usd.format(loan.monthlyPayment)),
      _DetailRow('Outstanding Balance', usd.format(loan.outstandingBalance)),
    ],
  );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}
