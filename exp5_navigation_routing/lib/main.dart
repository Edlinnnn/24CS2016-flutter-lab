import 'package:flutter/material.dart';
import 'details_screen.dart';
import 'result_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Performance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blueGrey, useMaterial3: true),

      // Named routes
      initialRoute: DetailsScreen.routeName,
      routes: {
        DetailsScreen.routeName: (context) => const DetailsScreen(),
        ResultScreen.routeName: (context) => const ResultScreen(),
      },
    );
  }
}