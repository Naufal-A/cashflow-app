import 'package:flutter/material.dart';

enum TransactionCategory {
  foodAndDrinks(
    label: 'Food & Drinks',
    icon: Icons.restaurant,
    color: Color(0xFFF59E0B), // Amber / Orange
  ),
  ridesAndTransport(
    label: 'Rides & Transport',
    icon: Icons.directions_car,
    color: Color(0xFF3B82F6), // Blue
  ),
  shopping(
    label: 'Shopping',
    icon: Icons.shopping_bag,
    color: Color(0xFFA855F7), // Purple
  ),
  billsAndUtilities(
    label: 'Bills & Utilities',
    icon: Icons.receipt_long,
    color: Color(0xFFEF4444), // Red
  ),
  salaryAndIncome(
    label: 'Salary / Income',
    icon: Icons.payments,
    color: Color(0xFF10B981), // Emerald Green
  ),
  entertainment(
    label: 'Entertainment',
    icon: Icons.movie,
    color: Color(0xFF14B8A6), // Teal
  ),
  other(
    label: 'Other',
    icon: Icons.category,
    color: Color(0xFF64748B), // Slate Grey
  );

  const TransactionCategory({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  Color get softBackground => color.withValues(alpha: 0.12);

  static TransactionCategory fromName(String name) {
    return TransactionCategory.values.firstWhere(
      (e) => e.name == name,
      orElse: () => TransactionCategory.other,
    );
  }
}
