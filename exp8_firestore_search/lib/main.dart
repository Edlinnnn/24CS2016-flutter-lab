import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'search_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Connect to the same Firebase project used in Exp 7
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const FirestoreSearchApp());
}

class FirestoreSearchApp extends StatelessWidget {
  const FirestoreSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Student Search',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.cyan, useMaterial3: true),
      home: const SearchScreen(),
    );
  }
}