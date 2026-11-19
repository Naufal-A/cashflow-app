import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/transaction_model.dart';
import 'widgets/add_transaction_sheet.dart';
import 'widgets/balance_card.dart';

void main() => runApp(const CashflowApp());

class CashflowApp extends StatelessWidget {
  const CashflowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cashflow Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorSchemeSeed: const Color(0xFF10B981),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _storageKey = 'cashflow_modular_v1';
  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);

  final _rp = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  List<TxItem> _items = [];
  String _filter = 'All'; // 'All', 'In', 'Out'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final list = (jsonDecode(raw) as List)
          .map((e) => TxItem.fromJson(e as Map<String, dynamic>))
          .toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      setState(() => _items = list);
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_items.map((e) => e.toJson()).toList()),
    );
  }

  double get _totalIn =>
      _items.where((e) => e.isIncome).fold(0, (s, e) => s + e.amount);

  double get _totalOut =>
      _items.where((e) => !e.isIncome).fold(0, (s, e) => s + e.amount);

  List<TxItem> get _filteredItems {
    if (_filter == 'In') return _items.where((e) => e.isIncome).toList();
    if (_filter == 'Out') return _items.where((e) => !e.isIncome).toList();
    return _items;
  }

  void _addTx(TxItem item) {
    setState(() {
      _items.add(item);
      _items.sort((a, b) => b.date.compareTo(a.date));
    });
    _saveData();
  }

  void _deleteTx(TxItem item) {
    setState(() => _items.removeWhere((e) => e.id == item.id));
    _saveData();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Deleted "${item.title}"'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Undo',
            textColor: _green,
            onPressed: () => _addTx(item),
          ),
        ),
      );
  }

  void _openAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AddTransactionModal(onSave: _addTx),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredItems;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        title: const Text(
          'Cashflow',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
            children: [
              BalanceCard(
                balance: _totalIn - _totalOut,
                totalIn: _totalIn,
                totalOut: _totalOut,
                formatter: _rp,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transactions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 6,
                    children: ['All', 'In', 'Out'].map((f) {
                      return ChoiceChip(
                        label: Text(f == 'All' ? 'All' : 'Cash $f'),
                        selected: _filter == f,
                        onSelected: (_) => setState(() => _filter = f),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (list.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        size: 48,
                        color: Color(0xFF94A3B8),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No transactions yet',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                      Text(
                        'Tap "+ Add" to record your cashflow.',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...list.map((tx) {
                  final color = tx.isIncome ? _green : _red;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Dismissible(
                      key: ValueKey(tx.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _deleteTx(tx),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: _red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: ListTile(
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: tx.category.color.withValues(
                            alpha: 0.15,
                          ),
                          child: Icon(
                            tx.category.icon,
                            color: tx.category.color,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          tx.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${tx.category.label} • ${DateFormat('d MMM yyyy').format(tx.date)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        trailing: Text(
                          '${tx.isIncome ? '+' : '-'}${_rp.format(tx.amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddModal,
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}
