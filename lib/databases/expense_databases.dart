import 'package:expense_tracker_app/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseDatabases extends ChangeNotifier {
  static late Isar isar;
  List<Expense> _allExpenses = [];
  bool _isLoading = false;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

  List<Expense> get allExpense => _allExpenses;
  bool get isLoading => _isLoading;

  Future<void> createNewExpense(Expense newExpense) async {
    await isar.writeTxn(() => isar.expenses.put(newExpense));

    await readExpense();
  }

  Future<void> readExpense() async {
    _isLoading = true;
    notifyListeners();

    List<Expense> fetchedExpense = await isar.expenses.where().findAll();

    _allExpenses.clear();
    _allExpenses.addAll(fetchedExpense);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateExpense(int id, Expense updatedExpense) async {
    updatedExpense.id = id;
    await isar.writeTxn(() => isar.expenses.put(updatedExpense));
    await readExpense();
  }

  Future<void> deleteExpense(int id) async {
    await isar.writeTxn(() => isar.expenses.delete(id));
    await readExpense();
  }

  Future<Map<String, double>> calculateMonthlyTotals() async {
    final Map<String, double> monthlyTotals = {};

    for (final expense in _allExpenses) {
      final String yearMonth = '${expense.date.year} - ${expense.date.month}';
      if (!monthlyTotals.containsKey(yearMonth)) {
        monthlyTotals[yearMonth] = 0.0;
      }
      monthlyTotals[yearMonth] = monthlyTotals[yearMonth]! + expense.amount;
    }

    return monthlyTotals;
  }

  int getStartMonth() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().month;
    }

    _allExpenses.sort((a, b) => a.date.compareTo(b.date));

    return _allExpenses.first.date.month;
  }
  
  Future<double> calculateCurrentMonthTotal() async {
    final int currentMonth = DateTime.now().month;
    final int currentYear = DateTime.now().year;

    final List<Expense> currentMonthExpense = _allExpenses.where(
      (expense) => expense.date.month == currentMonth && expense.date.year == currentYear,
    ).toList();

    final double total = currentMonthExpense.fold(0.0, (sum, expense) => sum + expense.amount);
    return total;
  }

  int getStartYear() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().year;
    }

    _allExpenses.sort((a, b) => a.date.compareTo(b.date));

    return _allExpenses.first.date.year;
  }
}
