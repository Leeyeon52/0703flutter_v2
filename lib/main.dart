// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // kIsWeb을 위해 필요

import 'package:t0703/app/router.dart';
import 'package:t0703/app/theme.dart';
import 'package:t0703/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:t0703/features/mypage/viewmodel/userinfo_viewmodel.dart';
import 'package:t0703/features/doctor_portal/viewmodel/telemedicine_request_list_viewmodel.dart';
import 'package:t0703/features/doctor_portal/viewmodel/telemedicine_detail_viewmodel.dart';
import 'package:t0703/features/doctor_portal/viewmodel/calendar_viewmodel.dart';


void main() {
  final String globalBaseUrl = kIsWeb
      ? "http://127.0.0.1:5000"
      : "http://10.0.2.2:5000";

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel(baseUrl: globalBaseUrl)),
        ChangeNotifierProvider(create: (context) => UserInfoViewModel()),
        ChangeNotifierProvider(create: (context) => TelemedicineRequestListViewModel(baseUrl: globalBaseUrl)),
        ChangeNotifierProvider(create: (context) => TelemedicineDetailViewModel(baseUrl: globalBaseUrl)),
        ChangeNotifierProvider(create: (context) => CalendarViewModel(baseUrl: globalBaseUrl)),
      ],
      child: const MediToothApp(),
    ),
  );
}

class MediToothApp extends StatelessWidget {
  const MediToothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MediTooth',
      theme: AppTheme.lightTheme, // app/theme.dart에서 정의된 테마 사용
      routerConfig: AppRouter.router, // app/router.dart에서 정의된 라우터 사용
      debugShowCheckedModeBanner: false,
    );
  }
}
