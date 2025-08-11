import 'package:expense_tracker_app/bar_graph/graph.dart';
import 'package:expense_tracker_app/components/my_listTile.dart';
import 'package:expense_tracker_app/databases/expense_databases.dart';
import 'package:expense_tracker_app/helper/helper_fun.dart';
import 'package:expense_tracker_app/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  Future<Map<String, double>>? _monthlyTotalFurture;
  Future<double>? _calculateCurrentMonthTotal;

  late AnimationController _fabAnimationController;
  late AnimationController _headerAnimationController;
  Animation<double>? _fabAnimation;
  Animation<double>? _headerAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final db = Provider.of<ExpenseDatabases>(context, listen: false);
      db.readExpense().then((_) {
        if (mounted) {
          setState(() {
            refreshGraphData();
          });
        }
      });
    });

    // Start animations
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _headerAnimationController.dispose();
    nameController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void refreshGraphData() {
    _monthlyTotalFurture = Provider.of<ExpenseDatabases>(
      context,
      listen: false,
    ).calculateMonthlyTotals();

    _calculateCurrentMonthTotal = Provider.of<ExpenseDatabases>(
      context,
      listen: false,
    ).calculateCurrentMonthTotal();
  }

  String getCurrentMonthName() {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[DateTime.now().month - 1];
  }

  void openNewExpenseBox() {
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
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.add, color: Colors.green),
            ),
            const SizedBox(width: 12),
            const Text(
              "Add New Expense",
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
                labelText: "Expense Name",
                prefixIcon: Icon(Icons.shopping_bag_outlined),
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
                labelText: "Amount",
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ],
        ),
        actions: [_cancelButton(), _createButton()],
      ),
    );
  }

  void openEditBox(Expense expense) {
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();
    nameController.text = existingName;
    amountController.text = existingAmount;

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
              child: Icon(Icons.edit, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            const Text(
              "Edit Expense",
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
                labelText: "Expense Name",
                prefixIcon: Icon(Icons.shopping_bag_outlined),
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
                labelText: "Amount",
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ],
        ),
        actions: [_cancelButton(), _editButton(expense)],
      ),
    );
  }

  void openDeleteBox(Expense expense) {
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
              child: Icon(Icons.delete_outline, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text(
              "Delete Expense",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to delete '${expense.name}'? This action cannot be undone.",
          style: TextStyle(color: Colors.grey.shade700),
        ),
        actions: [_cancelButton(), _deleteButton(expense.id)],
      ),
    );
  }

  void openDeleteAllDialog() {
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
              child: Icon(Icons.delete_sweep, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text(
              "Clear All Expenses",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to delete ALL expenses for this month? This action cannot be undone.",
          style: TextStyle(color: Colors.grey.shade700),
        ),
        actions: [
          _cancelButton(),
          MaterialButton(
            onPressed: () async {
              Navigator.pop(context);
              final expenses = Provider.of<ExpenseDatabases>(
                context,
                listen: false,
              );
              final currentMonth = DateTime.now().month;
              final currentYear = DateTime.now().year;

              final currentMonthExpenses = expenses.allExpense.where((expense) {
                return expense.date.year == currentYear &&
                    expense.date.month == currentMonth;
              }).toList();

              for (var expense in currentMonthExpenses) {
                await expenses.deleteExpense(expense.id);
              }

              refreshGraphData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("All expenses deleted"),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            color: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "Delete All",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          Container(
            height: 250,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          ...List.generate(
            5,
            (index) => Container(
              height: 70,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
        int startMonth = value.getStartMonth();
        int startYear = value.getStartYear();
        int currentMonth = DateTime.now().month;
        int currentYear = DateTime.now().year;

        int monthCount = calculateMonthlyCount(
          startYear,
          startMonth,
          currentMonth,
          currentYear,
        );

        List<Expense> currentMonthExpense = value.allExpense.where((expense) {
          return expense.date.year == currentYear &&
              expense.date.month == currentMonth;
        }).toList();

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: AnimatedBuilder(
              animation:
                  (_headerAnimation ??
                  const AlwaysStoppedAnimation<double>(1.0)),
              builder: (context, child) {
                return Transform.scale(
                  scale: (_headerAnimation?.value ?? 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.shade700,
                          Colors.blue.shade500,
                          Colors.blue.shade400,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            title: FutureBuilder<double>(
              future: _calculateCurrentMonthTotal,
              builder: (context, snapshot) {
                final amount = snapshot.data ?? 0.0;
                return AnimatedBuilder(
                  animation:
                      (_headerAnimation ??
                      const AlwaysStoppedAnimation<double>(1.0)),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        20 * (1 - (_headerAnimation?.value ?? 1.0)),
                      ),
                      child: Opacity(
                        opacity:
                            ((_headerAnimation?.value ?? 1.0).clamp(0.0, 1.0)
                                as double),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${getCurrentMonthName()} ${DateTime.now().year}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  formatAmount(amount),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            actions: currentMonthExpense.isNotEmpty
                ? [
                    AnimatedBuilder(
                      animation:
                          (_headerAnimation ??
                          const AlwaysStoppedAnimation<double>(1.0)),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: (_headerAnimation?.value ?? 1.0),
                          child: IconButton(
                            onPressed: openDeleteAllDialog,
                            icon: const Icon(
                              Icons.delete_sweep,
                              color: Colors.white,
                            ),
                            tooltip: "Clear all expenses",
                          ),
                        );
                      },
                    ),
                  ]
                : null,
          ),
          backgroundColor: Colors.grey.shade50,
          floatingActionButton: AnimatedBuilder(
            animation:
                (_fabAnimation ?? const AlwaysStoppedAnimation<double>(1.0)),
            builder: (context, child) {
              return Transform.scale(
                scale: (_fabAnimation?.value ?? 1.0),
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 72 + 24,
                  ),
                  child: FloatingActionButton.extended(
                    onPressed: openNewExpenseBox,
                    backgroundColor: Colors.blue.shade600,
                    elevation: 8,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      "Add Expense",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          body: SafeArea(
            child: FutureBuilder<Map<String, double>>(
              future: _monthlyTotalFurture,
              builder: (context, snapshot) {
                if (value.isLoading ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerLoader();
                }

                return Column(
                  children: [
                    // Graph Section
                    Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 0,
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.bar_chart,
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Monthly Overview",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 200,
                            child:
                                snapshot.connectionState == ConnectionState.done
                                ? () {
                                    Map<String, double> monthlyTotals =
                                        snapshot.data ?? {};
                                    List<double> monthlySummary = List.generate(
                                      monthCount,
                                      (index) {
                                        int year =
                                            startYear +
                                            (startMonth + index - 1) ~/ 12;
                                        int month =
                                            (startMonth + index - 1) % 12 + 1;
                                        String yearMonthKey = '$year - $month';
                                        return monthlyTotals[yearMonthKey] ??
                                            0.0;
                                      },
                                    );

                                    return Graph(
                                      monthlySummary: monthlySummary,
                                      startMonth: startMonth,
                                    );
                                  }()
                                : const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

                    // Expenses List Section
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "Recent Expenses",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "${currentMonthExpense.length}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: currentMonthExpense.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(24),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.receipt_long,
                                              size: 48,
                                              color: Colors.grey.shade400,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            "No expenses yet",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Add your first expense to get started",
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
                                      itemCount: currentMonthExpense.length,
                                      itemBuilder: (context, index) {
                                        int reversedIndex =
                                            currentMonthExpense.length -
                                            1 -
                                            index;
                                        Expense individualExpense =
                                            currentMonthExpense[reversedIndex];

                                        return AnimatedContainer(
                                          duration: Duration(
                                            milliseconds: 300 + (index * 50),
                                          ),
                                          curve: Curves.easeOutBack,
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: MyListtile(
                                            title:
                                                '${individualExpense.name} · ${formatDate(individualExpense.date)}',
                                            trailing: formatAmount(
                                              individualExpense.amount,
                                            ),
                                            onEditPressed: (context) =>
                                                openEditBox(individualExpense),
                                            onDeletePressed: (context) =>
                                                openDeleteBox(
                                                  individualExpense,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        Navigator.pop(context);
        nameController.clear();
        amountController.clear();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
    );
  }

  Widget _createButton() {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          Navigator.pop(context);

          Expense newExpense = Expense(
            name: nameController.text,
            amount: convertStringToDouble(amountController.text),
            date: DateTime.now(),
          );

          await context.read<ExpenseDatabases>().createNewExpense(newExpense);

          refreshGraphData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text("Expense added successfully"),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }

          nameController.clear();
          amountController.clear();
        }
      },
      color: Colors.green,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: const Text("Save", style: TextStyle(color: Colors.white)),
    );
  }

  Widget _editButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty ||
            amountController.text.isNotEmpty) {
          Navigator.pop(context);
          Expense updatedExpense = Expense(
            name: nameController.text.isNotEmpty
                ? nameController.text
                : expense.name,
            amount: amountController.text.isNotEmpty
                ? convertStringToDouble(amountController.text)
                : expense.amount,
            date: DateTime.now(),
          );

          int existingId = expense.id;
          await context.read<ExpenseDatabases>().updateExpense(
            existingId,
            updatedExpense,
          );

          refreshGraphData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text("Expense updated successfully"),
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

          nameController.clear();
          amountController.clear();
        }
      },
      color: Colors.blue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: const Text("Save", style: TextStyle(color: Colors.white)),
    );
  }

  Widget _deleteButton(int id) {
    return MaterialButton(
      onPressed: () async {
        Navigator.pop(context);

        await context.read<ExpenseDatabases>().deleteExpense(id);
        refreshGraphData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.delete, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text("Expense deleted successfully"),
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

        nameController.clear();
        amountController.clear();
      },
      color: Colors.red,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: const Text("Delete", style: TextStyle(color: Colors.white)),
    );
  }
}
