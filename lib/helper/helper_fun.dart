import 'package:intl/intl.dart';

double convertStringToDouble(String string) {
  final double? amount = double.tryParse(string.replaceAll(',', ''));
  return amount ?? 0.0;
}

String formatAmount(double amount) {
  final format = NumberFormat.currency(
    locale: "en_US",
    symbol: "\$",
    decimalDigits: 2,
  );
  return format.format(amount);
}

String formatDate(DateTime date) {
  final df = DateFormat('MMM d, y');
  return df.format(date);
}

int calculateMonthlyCount(
  int startYear,
  startMonth,
  currentMonth,
  currentYear,
) {
  final int monthCount =
      (currentYear - startYear) * 12 + currentMonth - startMonth + 1;
  return monthCount;
}

String getCurrentMonthName() {
  final DateTime now = DateTime.now();
  const List<String> months = [
    "JAN",
    "FEB",
    "MAR",
    "APR",
    "MAY",
    "JUN",
    "JUL",
    "AUG",
    "SEP",
    "OCT",
    "NOV",
    "DEC",
  ];
  return months[now.month - 1];
}
