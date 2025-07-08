import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/score_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ScoreProvider(),
      child: MaterialApp(
        title: 'Digital Score Card',
        theme: ThemeData(primarySwatch: Colors.indigo),
        home: HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
