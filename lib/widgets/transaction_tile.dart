import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/cashflow_provider.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onDismissed;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onDismissed,
  });

  static const Color _emeraldGreen = Color(0xFF10B981);
  static const Color _coralRed = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CashflowProvider>();
    final formattedDate = DateFormat('d MMM yyyy').format(transaction.date);
    final amountColor = transaction.isIncome ? _emeraldGreen : _coralRed;
    final prefix = transaction.isIncome ? '+' : '-';
    final formattedAmount =
        '$prefix${provider.formatCurrency(transaction.amount)}';

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: _coralRed,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white),
            SizedBox(width: 6),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: transaction.category.softBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                transaction.category.icon,
                color: transaction.category.color,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: transaction.category.softBackground,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          transaction.category.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: transaction.category.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              formattedAmount,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
