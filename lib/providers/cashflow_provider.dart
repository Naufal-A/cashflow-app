import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction_model.dart';

enum TransactionFilter { all, income, expense }

class CashflowProvider extends ChangeNotifier {
  static const String _storageKey = 'cashflow_transactions_v1';

  final List<TransactionModel> _transactions = [];
  TransactionFilter _filter = TransactionFilter.all;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  TransactionFilter get filter => _filter;

  List<TransactionModel> get filteredTransactions {
    switch (_filter) {
      case TransactionFilter.all:
        return List.unmodifiable(_transactions);
      case TransactionFilter.income:
        return _transactions.where((t) => t.isIncome).toList();
      case TransactionFilter.expense:
        return _transactions.where((t) => !t.isIncome).toList();
    }
  }

  double get totalIncome => _transactions
      .where((t) => t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => !t.isIncome)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        _transactions
          ..clear()
          ..addAll(
            list.map(
              (e) => TransactionModel.fromJson(e as Map<String, dynamic>),
            ),
          );
        _sort();
      }
    } catch (e) {
      debugPrint('Failed to load transactions: $e');
    }
    _isLoaded = true;
    notifyListeners();
  }

  void setFilter(TransactionFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }

  void add(TransactionModel transaction) {
    _transactions.add(transaction);
    _sort();
    notifyListeners();
    unawaited(_persist());
  }

  void remove(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
    unawaited(_persist());
  }

  void _sort() {
    _transactions.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      return byDate != 0 ? byDate : b.id.compareTo(a.id);
    });
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_transactions.map((t) => t.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Failed to save transactions: $e');
    }
  }
}
