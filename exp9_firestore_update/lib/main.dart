import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'update_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Connect to the same Firebase project used in Exp 7 and Exp 8
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const UpdateStudentApp());
}

class UpdateStudentApp extends StatelessWidget {
  const UpdateStudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Update Student Information',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const UpdateScreen(),
    );
  }
}