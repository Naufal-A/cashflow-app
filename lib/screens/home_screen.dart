import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/cashflow_provider.dart';
import '../widgets/add_transaction_sheet.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openAddTransactionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTransactionSheet(),
    );
  }

  void _handleDelete(
    BuildContext context,
    CashflowProvider provider,
    TransactionModel transaction,
  ) {
    provider.deleteTransaction(transaction.id);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Deleted "${transaction.title}"'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          action: SnackBarAction(
            label: 'Undo',
            textColor: const Color(0xFF10B981),
            onPressed: () => provider.restoreTransaction(transaction),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CashflowProvider>();
    final transactions = provider.filteredTransactions;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Cashflow',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    letterSpacing: -0.4,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const BalanceCard(),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Transactions',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                _FilterChipsRow(
                                  selectedFilter: provider.filter,
                                  onSelected: provider.setFilter,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (transactions.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyTransactionsState(filter: provider.filter),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        sliver: SliverList.separated(
                          itemCount: transactions.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = transactions[index];
                            return TransactionTile(
                              transaction: item,
                              onDismissed: () =>
                                  _handleDelete(context, provider, item),
                            );
                          },
                        ),
                      ),
                  ],
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddTransactionSheet(context),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Transaction',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _FilterChipsRow extends StatelessWidget {
  final TransactionFilter selectedFilter;
  final ValueChanged<TransactionFilter> onSelected;

  const _FilterChipsRow({
    required this.selectedFilter,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildChip(
          label: 'All',
          filter: TransactionFilter.all,
          activeColor: const Color(0xFF0F172A),
        ),
        const SizedBox(width: 6),
        _buildChip(
          label: 'Cash In',
          filter: TransactionFilter.income,
          activeColor: const Color(0xFF10B981),
        ),
        const SizedBox(width: 6),
        _buildChip(
          label: 'Cash Out',
          filter: TransactionFilter.expense,
          activeColor: const Color(0xFFEF4444),
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required TransactionFilter filter,
    required Color activeColor,
  }) {
    final isSelected = selectedFilter == filter;
    return GestureDetector(
      onTap: () => onSelected(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}

class _EmptyTransactionsState extends StatelessWidget {
  final TransactionFilter filter;

  const _EmptyTransactionsState({required this.filter});

  @override
  Widget build(BuildContext context) {
    String title = 'No transactions yet';
    String subtitle =
        'Tap "+ Add Transaction" below to record your first entry.';

    if (filter == TransactionFilter.income) {
      title = 'No Cash In records';
      subtitle = 'Add an income entry or switch back to "All".';
    } else if (filter == TransactionFilter.expense) {
      title = 'No Cash Out records';
      subtitle = 'Add an expense entry or switch back to "All".';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 96),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0).withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 40,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
