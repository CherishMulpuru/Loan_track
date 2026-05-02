// lib/screens/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import '../models/loan.dart';

class PaymentScreen extends StatefulWidget {
  final int loanId;
  const PaymentScreen({super.key, required this.loanId});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Loan? _loan;
  List<ScheduleEntry> _pending = [];
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _method = 'ACH';
  int? _scheduleId;
  bool _loading = false;
  String? _success;
  String? _error;

  final _usd = NumberFormat.currency(locale: 'en_US', symbol: '\$');
  final _methods = ['ACH', 'DEBIT_CARD', 'CHECK', 'ONLINE'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final loan = await apiService.getLoan(widget.loanId);
    final schedule = await apiService.getSchedule(widget.loanId);
    if (mounted) setState(() {
      _loan = loan;
      _amountCtrl.text = loan.monthlyPayment.toStringAsFixed(2);
      _pending = schedule.where((s) => s.status == 'PENDING').take(3).toList();
    });
  }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; _success = null; });
    try {
      final result = await apiService.makePayment(
        loanId: widget.loanId,
        amount: double.parse(_amountCtrl.text),
        paymentMethod: _method,
        scheduleId: _scheduleId,
        note: _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
      );
      setState(() => _success = 'Confirmed! #${result['confirmationNumber']}');
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) context.go('/loans/${widget.loanId}');
    } catch (e) {
      setState(() => _error = 'Payment failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make a Payment'),
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        leading: BackButton(onPressed: () => context.go('/loans/${widget.loanId}')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_loan != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_loan!.loanNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Balance: ${_usd.format(_loan!.outstandingBalance)}',
                      style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            if (_success != null)
              _StatusBanner(_success!, isSuccess: true),
            if (_error != null)
              _StatusBanner(_error!, isSuccess: false),

            if (_pending.isNotEmpty) ...[
              const Text('Apply to Schedule Entry',
                style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              DropdownButtonFormField<int?>(
                value: _scheduleId,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(value: null, child: Text('— None —')),
                  ..._pending.map((e) => DropdownMenuItem(
                    value: e.id,
                    child: Text('Payment #${e.paymentNumber} — ${e.dueDate}'),
                  )),
                ],
                onChanged: (v) => setState(() => _scheduleId = v),
              ),
              const SizedBox(height: 16),
            ],

            const Text('Amount', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _method,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _methods.map((m) => DropdownMenuItem(
                value: m,
                child: Text(m.replaceAll('_', ' ')),
              )).toList(),
              onChanged: (v) => setState(() => _method = v!),
            ),
            const SizedBox(height: 16),

            const Text('Note (optional)', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. Extra principal payment',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 28),

            FilledButton(
              onPressed: (_loading || _success != null) ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _loading
                ? const SizedBox(height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Submit Payment', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String message;
  final bool isSuccess;

  const _StatusBanner(this.message, {required this.isSuccess});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: isSuccess ? Colors.green.shade200 : Colors.red.shade200),
    ),
    child: Text(message,
      style: TextStyle(color: isSuccess ? Colors.green.shade800 : Colors.red.shade800)),
  );
}
