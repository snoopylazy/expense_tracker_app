import 'package:expense_tracker_app/databases/expense_databases.dart';
import 'package:expense_tracker_app/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ExpenseDatabases.initialize();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ExpenseDatabases(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
