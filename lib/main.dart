import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cashflow_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => CashflowProvider()..loadTransactions(),
      child: const CashflowApp(),
    ),
  );
}

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF10B981),
          surface: const Color(0xFFF8FAFC),
        ),
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
