import 'package:expense_tracker_app/helper/helper_fun.dart';
import 'package:expense_tracker_app/models/expense.dart';
import 'package:expense_tracker_app/databases/expense_databases.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime? _selectedDate;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? now;
    final firstDate = DateTime(now.year - 5, 1, 1);
    final lastDate = DateTime(now.year + 5, 12, 31);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select a date to search',
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 8,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              itemBuilder: (context, index) => Container(
                height: 64,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabases>(
      builder: (context, value, child) {
        List<Expense> list = List.from(value.allExpense);
        list.sort((a, b) => b.date.compareTo(a.date));

        if (_selectedDate != null) {
          list = list.where((e) => _isSameDay(e.date, _selectedDate!)).toList();
        }

        if (value.isLoading) {
          return _buildShimmerLoader();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter/Search controls
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_month),
                        label: const Text('Select date'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_selectedDate != null)
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() => _selectedDate = null);
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _selectedDate == null
                        ? 'Showing: All expenses'
                        : 'Showing: ${formatDate(_selectedDate!)}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.history,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No expenses found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pick another date or add an expense',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 120),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final e = list[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: _HistoryTile(
                            expense: e,
                            onUpdated: () {
                              // Trigger rebuild
                              setState(() {});
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onUpdated;
  const _HistoryTile({required this.expense, required this.onUpdated});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text('${expense.name} · ${formatDate(expense.date)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatAmount(expense.amount),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            _IconBtn(
              icon: Icons.edit_outlined,
              color: Colors.blue,
              onTap: () => _openEdit(context, expense),
            ),
            const SizedBox(width: 8),
            _IconBtn(
              icon: Icons.delete_outline,
              color: Colors.red,
              onTap: () => _openDelete(context, expense),
            ),
          ],
        ),
      ),
    );
  }

  void _openEdit(BuildContext context, Expense expense) {
    final nameController = TextEditingController(text: expense.name);
    final amountController = TextEditingController(
      text: expense.amount.toString(),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            const Text(
              'Edit Expense',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Expense Name',
                prefixIcon: const Icon(Icons.shopping_bag_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ],
        ),
        actions: [
          MaterialButton(
            onPressed: () => Navigator.pop(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          MaterialButton(
            onPressed: () async {
              if (nameController.text.isEmpty && amountController.text.isEmpty) {
                return;
              }

              final updated = Expense(
                name: nameController.text.isNotEmpty
                    ? nameController.text
                    : expense.name,
                amount: amountController.text.isNotEmpty
                    ? convertStringToDouble(amountController.text)
                    : expense.amount,
                date: DateTime.now(),
              );
              updated.id = expense.id;

              await context.read<ExpenseDatabases>().updateExpense(
                expense.id,
                updated,
              );
              onUpdated();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: const [
                        Icon(Icons.edit, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Expense updated successfully'),
                      ],
                    ),
                    backgroundColor: Colors.blue,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            color: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openDelete(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text(
              'Delete Expense',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text("Are you sure you want to delete '${expense.name}'?"),
        actions: [
          MaterialButton(
            onPressed: () => Navigator.pop(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          MaterialButton(
            color: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            onPressed: () async {
              await context.read<ExpenseDatabases>().deleteExpense(expense.id);
              onUpdated();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: const [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Expense deleted successfully'),
                      ],
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
