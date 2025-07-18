import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/score_provider.dart';
import 'screens/home_screen.dart';
import 'screens/report_list_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScoreProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Digital Score Card',
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => HomeScreen(),
          '/reports': (context) => ReportListScreen(),
        },
      ),
    );
  }
}