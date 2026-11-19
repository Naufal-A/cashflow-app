import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/categories.dart';
import '../models/transaction_model.dart';

enum TransactionFilter { all, income, expense }

class CashflowProvider extends ChangeNotifier {
  static const String _storageKey = 'cashflow_transactions_v1';

  final List<TransactionModel> _transactions = [];
  TransactionFilter _filter = TransactionFilter.all;
  bool _isLoading = true;

  // Currency formatter configured for Indonesian Rupiah (e.g., Rp 50.000)
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  List<TransactionModel> get allTransactions =>
      List.unmodifiable(_transactions);

  List<TransactionModel> get filteredTransactions {
    switch (_filter) {
      case TransactionFilter.income:
        return _transactions.where((t) => t.isIncome).toList();
      case TransactionFilter.expense:
        return _transactions.where((t) => !t.isIncome).toList();
      case TransactionFilter.all:
        return List.unmodifiable(_transactions);
    }
  }

  TransactionFilter get filter => _filter;
  bool get isLoading => _isLoading;

  double get totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalBalance => totalIncome - totalExpense;

  String formatCurrency(double amount) {
    return _currencyFormatter.format(amount);
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_storageKey);

      if (rawJson != null && rawJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
        _transactions
          ..clear()
          ..addAll(
            decoded.map(
              (item) => TransactionModel.fromJson(item as Map<String, dynamic>),
            ),
          );
        _sortTransactions();
      }
    } catch (e) {
      debugPrint('Failed to load transactions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_transactions.map((t) => t.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Failed to save transactions: $e');
    }
  }

  void _sortTransactions() {
    _transactions.sort((a, b) => b.date.compareTo(a.date));
  }

  void setFilter(TransactionFilter newFilter) {
    if (_filter == newFilter) return;
    _filter = newFilter;
    notifyListeners();
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required TransactionCategory category,
    required DateTime date,
  }) async {
    final transaction = TransactionModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      amount: amount,
      type: type,
      category: category,
      date: date,
    );

    _transactions.add(transaction);
    _sortTransactions();
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> restoreTransaction(TransactionModel transaction) async {
    _transactions.add(transaction);
    _sortTransactions();
    notifyListeners();
    await _saveToStorage();
  }
}
