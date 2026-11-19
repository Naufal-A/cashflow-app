import 'package:flutter/material.dart';

enum TxCategory {
  food('Food & Drinks', Icons.restaurant, Color(0xFFF59E0B)),
  transport('Rides & Transport', Icons.directions_car, Color(0xFF3B82F6)),
  shopping('Shopping', Icons.shopping_bag, Color(0xFFA855F7)),
  bills('Bills & Utilities', Icons.receipt_long, Color(0xFFEF4444)),
  salary('Salary / Income', Icons.payments, Color(0xFF10B981)),
  entertainment('Entertainment', Icons.movie, Color(0xFF14B8A6)),
  other('Other', Icons.category, Color(0xFF64748B));

  const TxCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

class TxItem {
  final String id;
  final String title;
  final double amount;
  final bool isIncome;
  final TxCategory category;
  final DateTime date;

  const TxItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'isIncome': isIncome,
    'category': category.name,
    'date': date.toIso8601String(),
  };

  factory TxItem.fromJson(Map<String, dynamic> json) => TxItem(
    id: json['id'] as String,
    title: json['title'] as String,
    amount: (json['amount'] as num).toDouble(),
    isIncome: json['isIncome'] as bool,
    category: TxCategory.values.firstWhere(
      (e) => e.name == json['category'],
      orElse: () => TxCategory.other,
    ),
    date: DateTime.parse(json['date'] as String),
  );
}
