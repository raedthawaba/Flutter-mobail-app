// Minimal main.dart - Backup solution
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const PalestineMartyrsApp());
}

class PalestineMartyrsApp extends StatelessWidget {
  const PalestineMartyrsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'فلسطين الشهداء',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('فلسطين الشهداء'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text('التطبيق يعمل بنجاح!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
