import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const background = Color(0xFFF8FAFC);
  static const income = Color(0xFF10B981);
  static const expense = Color(0xFFEF4444);
  static const border = Color(0xFFE2E8F0);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
}

extension ColorTint on Color {
  /// Returns this color with the given opacity (0.0 - 1.0).
  Color tint(double opacity) => withAlpha((opacity * 255).round());
}

enum TransactionCategory {
  food('Food & Drinks', Icons.restaurant, Color(0xFFF59E0B)),
  transport('Rides & Transport', Icons.directions_car, Color(0xFF3B82F6)),
  shopping('Shopping', Icons.shopping_bag, Color(0xFFA855F7)),
  bills('Bills & Utilities', Icons.receipt_long, Color(0xFFF4511E)),
  salary('Salary / Income', Icons.payments, Color(0xFF059669)),
  entertainment('Entertainment', Icons.movie, Color(0xFF14B8A6)),
  other('Other', Icons.category, Color(0xFF64748B));

  const TransactionCategory(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}
