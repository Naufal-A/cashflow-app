import '../constants/categories.dart';

enum TransactionType {
  income,
  expense;

  static TransactionType fromName(String name) {
    return TransactionType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => TransactionType.expense,
    );
  }
}

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final DateTime date;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  bool get isIncome => type == TransactionType.income;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.name,
      'category': category.name,
      'date': date.toIso8601String(),
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.fromName(json['type'] as String),
      category: TransactionCategory.fromName(json['category'] as String),
      date: DateTime.parse(json['date'] as String),
    );
  }
}
