// lib/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/loan.dart';

const _baseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://10.0.2.2:8080/api/v1',
);

class ApiService {
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    // Attach JWT on every request
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  // ─── Auth ──────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    await _storage.write(key: 'jwt_token', value: res.data['token']);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final res = await _dio.post('/auth/register', data: {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
    });
    await _storage.write(key: 'jwt_token', value: res.data['token']);
    return res.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'user_data');
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'jwt_token');
    return token != null;
  }

  // ─── Loans ─────────────────────────────────────────────────────────────────

  Future<List<LoanSummary>> getLoans() async {
    final res = await _dio.get('/loans');
    return (res.data as List).map((e) => LoanSummary.fromJson(e)).toList();
  }

  Future<Loan> getLoan(int id) async {
    final res = await _dio.get('/loans/$id');
    return Loan.fromJson(res.data);
  }

  Future<Loan> createLoan({
    required double principalAmount,
    required double interestRate,
    required int termMonths,
    required String startDate,
    required String loanType,
  }) async {
    final res = await _dio.post('/loans', data: {
      'principalAmount': principalAmount,
      'interestRate': interestRate,
      'termMonths': termMonths,
      'startDate': startDate,
      'loanType': loanType,
    });
    return Loan.fromJson(res.data);
  }

  // ─── Schedule ──────────────────────────────────────────────────────────────

  Future<List<ScheduleEntry>> getSchedule(int loanId) async {
    final res = await _dio.get('/loans/$loanId/schedule');
    return (res.data as List).map((e) => ScheduleEntry.fromJson(e)).toList();
  }

  // ─── Payments ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> makePayment({
    required int loanId,
    required double amount,
    required String paymentMethod,
    int? scheduleId,
    String? note,
  }) async {
    final res = await _dio.post('/loans/$loanId/payments', data: {
      'amount': amount,
      'paymentMethod': paymentMethod,
      if (scheduleId != null) 'scheduleId': scheduleId,
      if (note != null) 'note': note,
    });
    return res.data as Map<String, dynamic>;
  }

  // ─── Forecast ──────────────────────────────────────────────────────────────

  Future<ForecastResponse> getForecast({int months = 6}) async {
    final res = await _dio.get('/forecast?months=$months');
    return ForecastResponse.fromJson(res.data);
  }
}
