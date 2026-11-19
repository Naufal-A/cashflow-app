import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';

class AddTransactionModal extends StatefulWidget {
  final ValueChanged<TxItem> onSave;

  const AddTransactionModal({super.key, required this.onSave});

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  bool _isIncome = false;
  TxCategory _category = TxCategory.food;
  DateTime _date = DateTime.now();

  static const _green = Color(0xFF10B981);
  static const _red = Color(0xFFEF4444);

  Color get _accent => _isIncome ? _green : _red;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    if (_titleCtrl.text.trim().isEmpty || amount <= 0) return;

    widget.onSave(
      TxItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: _titleCtrl.text.trim(),
        amount: amount,
        isIncome: _isIncome,
        category: _category,
        date: _date,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'New Transaction',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: false,
                      label: Text('Cash Out'),
                      icon: Icon(Icons.arrow_upward),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text('Cash In'),
                      icon: Icon(Icons.arrow_downward),
                    ),
                  ],
                  selected: {_isIncome},
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: _accent,
                    selectedForegroundColor: Colors.white,
                  ),
                  onSelectionChanged: (val) => setState(() {
                    _isIncome = val.first;
                    _category = _isIncome ? TxCategory.salary : TxCategory.food;
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _accent,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixText: 'Rp ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _titleCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Transaction Name',
                    hintText: 'e.g., Lunch at Warteg',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Category',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: TxCategory.values.map((cat) {
                    final selected = _category == cat;
                    return ChoiceChip(
                      avatar: Icon(
                        cat.icon,
                        size: 16,
                        color: selected ? Colors.white : cat.color,
                      ),
                      label: Text(cat.label),
                      selected: selected,
                      selectedColor: cat.color,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      onSelected: (_) => setState(() => _category = cat),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                  icon: Icon(Icons.calendar_today, size: 16, color: _accent),
                  label: Text(DateFormat('d MMM yyyy').format(_date)),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: _accent),
                    onPressed: _submit,
                    child: Text(
                      _isIncome ? 'Save Cash In' : 'Save Cash Out',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
