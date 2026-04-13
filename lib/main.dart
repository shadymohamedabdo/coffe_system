import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'data/dashboard_cubit/dashboard_cubit.dart';
import 'data/sale_cubit/sale_cubit.dart';
import 'data/screens/login_screen.dart';

import 'data/user_cubit/user_cubit.dart';



void main() {

  // تهيئة قاعدة البيانات للـ Windows/Desktop
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const CoffeePOSApp());
}

class CoffeePOSApp extends StatelessWidget {
  const CoffeePOSApp({super.key});

  @override
  Widget build(BuildContext context) {

    return       MaterialApp(
      title: 'Coffee POS',
      theme: ThemeData(primarySwatch: Colors.brown),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );

    //   MultiBlocProvider(
    //   // providers: [
    //   //   BlocProvider<DashboardCubit>(
    //   //     create: (_) => getIt<DashboardCubit>()..loadData(),
    //   //   ),
    //   //   BlocProvider<ShiftReportCubit>(
    //   //     create: (_) => getIt<ShiftReportCubit>()..loadShifts(),
    //   //   ),
    //   //   BlocProvider<MonthlyReportCubit>(
    //   //     create: (_) => getIt<MonthlyReportCubit>(),
    //   //   ),
    //   //   BlocProvider<ProductsCubit>(
    //   //     create: (_) => getIt<ProductsCubit>(),
    //   //   ),
    //   //   BlocProvider<UsersCubit>(
    //   //     create: (_) => getIt<UsersCubit>()..loadEmployees(),
    //   //   ),
    //   //   BlocProvider<AddSaleCubit>(
    //   //     create: (_) => getIt<AddSaleCubit>(),
    //   //   ),
    //   // ],
    //   child:
    // );
  }
}



