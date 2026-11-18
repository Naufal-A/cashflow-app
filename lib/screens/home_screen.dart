import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/categories.dart';
import '../models/transaction_model.dart';
import '../providers/cashflow_provider.dart';
import '../widgets/add_transaction_sheet.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_tile.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _deleteTransaction(BuildContext context, TransactionModel tx) {
    final provider = context.read<CashflowProvider>();
    provider.remove(tx.id);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('"${tx.title}" deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => provider.add(tx),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CashflowProvider>();
    final items = provider.filteredTransactions;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddTransactionSheet.show(context),
        backgroundColor: AppColors.textPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Transaction',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: !provider.isLoaded
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: _Header()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: BalanceCard(
                        balance: provider.balance,
                        totalIncome: provider.totalIncome,
                        totalExpense: provider.totalExpense,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                      child: _FilterRow(
                        selected: provider.filter,
                        onSelected: provider.setFilter,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
                      child: Text(
                        'Transaction History',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  if (items.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyState(filter: provider.filter),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                      sliver: SliverList.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final tx = items[index];
                          return TransactionTile(
                            key: ValueKey(tx.id),
                            transaction: tx,
                            onDismissed: () => _deleteTransaction(context, tx),
                          );
                        },
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cashflow',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Track every rupiah in and out',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final TransactionFilter selected;
  final ValueChanged<TransactionFilter> onSelected;

  const _FilterRow({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        _chip('All', TransactionFilter.all, AppColors.textPrimary),
        _chip('Cash In', TransactionFilter.income, AppColors.income),
        _chip('Cash Out', TransactionFilter.expense, AppColors.expense),
      ],
    );
  }

  Widget _chip(String label, TransactionFilter value, Color color) {
    final isSelected = selected == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (_) => onSelected(value),
      selectedColor: color,
      backgroundColor: Colors.white,
      side: BorderSide(color: isSelected ? color : AppColors.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final TransactionFilter filter;

  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final String title;
    final String subtitle;
    switch (filter) {
      case TransactionFilter.all:
        title = 'No transactions yet';
        subtitle =
            'Tap "Add Transaction" to record your first cash in or cash out.';
        break;
      case TransactionFilter.income:
        title = 'No cash in yet';
        subtitle = 'Income you add will show up here.';
        break;
      case TransactionFilter.expense:
        title = 'No cash out yet';
        subtitle = 'Expenses you add will show up here.';
        break;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 24, 32, 96),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.income.tint(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 42,
              color: AppColors.income,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
