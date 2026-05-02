// lib/models/loan.dart

class LoanSummary {
  final int id;
  final String loanNumber;
  final String loanType;
  final String status;
  final double outstandingBalance;
  final double monthlyPayment;
  final String endDate;

  const LoanSummary({
    required this.id,
    required this.loanNumber,
    required this.loanType,
    required this.status,
    required this.outstandingBalance,
    required this.monthlyPayment,
    required this.endDate,
  });

  factory LoanSummary.fromJson(Map<String, dynamic> json) => LoanSummary(
        id: json['id'],
        loanNumber: json['loanNumber'],
        loanType: json['loanType'],
        status: json['status'],
        outstandingBalance: (json['outstandingBalance'] as num).toDouble(),
        monthlyPayment: (json['monthlyPayment'] as num).toDouble(),
        endDate: json['endDate'],
      );
}

class Loan {
  final int id;
  final String loanNumber;
  final double principalAmount;
  final double interestRate;
  final int termMonths;
  final String startDate;
  final String endDate;
  final String loanType;
  final String status;
  final double monthlyPayment;
  final double outstandingBalance;

  const Loan({
    required this.id,
    required this.loanNumber,
    required this.principalAmount,
    required this.interestRate,
    required this.termMonths,
    required this.startDate,
    required this.endDate,
    required this.loanType,
    required this.status,
    required this.monthlyPayment,
    required this.outstandingBalance,
  });

  factory Loan.fromJson(Map<String, dynamic> json) => Loan(
        id: json['id'],
        loanNumber: json['loanNumber'],
        principalAmount: (json['principalAmount'] as num).toDouble(),
        interestRate: (json['interestRate'] as num).toDouble(),
        termMonths: json['termMonths'],
        startDate: json['startDate'],
        endDate: json['endDate'],
        loanType: json['loanType'],
        status: json['status'],
        monthlyPayment: (json['monthlyPayment'] as num).toDouble(),
        outstandingBalance: (json['outstandingBalance'] as num).toDouble(),
      );
}

class ScheduleEntry {
  final int id;
  final int paymentNumber;
  final String dueDate;
  final double scheduledAmount;
  final double principalPortion;
  final double interestPortion;
  final double beginningBalance;
  final double endingBalance;
  final String status;

  const ScheduleEntry({
    required this.id,
    required this.paymentNumber,
    required this.dueDate,
    required this.scheduledAmount,
    required this.principalPortion,
    required this.interestPortion,
    required this.beginningBalance,
    required this.endingBalance,
    required this.status,
  });

  factory ScheduleEntry.fromJson(Map<String, dynamic> json) => ScheduleEntry(
        id: json['id'],
        paymentNumber: json['paymentNumber'],
        dueDate: json['dueDate'],
        scheduledAmount: (json['scheduledAmount'] as num).toDouble(),
        principalPortion: (json['principalPortion'] as num).toDouble(),
        interestPortion: (json['interestPortion'] as num).toDouble(),
        beginningBalance: (json['beginningBalance'] as num).toDouble(),
        endingBalance: (json['endingBalance'] as num).toDouble(),
        status: json['status'],
      );
}

class ForecastEntry {
  final String dueDate;
  final String loanNumber;
  final String loanType;
  final double amount;
  final String status;

  const ForecastEntry({
    required this.dueDate,
    required this.loanNumber,
    required this.loanType,
    required this.amount,
    required this.status,
  });

  factory ForecastEntry.fromJson(Map<String, dynamic> json) => ForecastEntry(
        dueDate: json['dueDate'],
        loanNumber: json['loanNumber'],
        loanType: json['loanType'],
        amount: (json['amount'] as num).toDouble(),
        status: json['status'],
      );
}

class ForecastResponse {
  final List<ForecastEntry> entries;
  final double totalDue;
  final int months;

  const ForecastResponse({
    required this.entries,
    required this.totalDue,
    required this.months,
  });

  factory ForecastResponse.fromJson(Map<String, dynamic> json) => ForecastResponse(
        entries: (json['entries'] as List)
            .map((e) => ForecastEntry.fromJson(e))
            .toList(),
        totalDue: (json['totalDue'] as num).toDouble(),
        months: json['months'],
      );
}
