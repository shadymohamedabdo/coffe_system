import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'data/screens/login_screen.dart';

Future<void> main() async {
  // 1. لازم ده يكون أول سطر لضمان عمل أي دوال خارجية
  WidgetsFlutterBinding.ensureInitialized();

  // 2. تهيئة الـ ffi للويندوز (لازم قبل getDatabasesPath)
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  // 3. دلوقتي تقدر تجيب المسار وتطبعه بأمان
  final dbFolder = await getDatabasesPath();
  final fullPath = join(dbFolder, 'coffee_pos.db'); // تأكد من اسم الملف اللي بتستخدمه في الهيلبر

  print("--------------------------------------------------");
  print("✅ Database Full Path: $fullPath");
  print("--------------------------------------------------");

  runApp(const CoffeePOSApp());
}

class CoffeePOSApp extends StatelessWidget {
  const CoffeePOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Coffee POS',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}