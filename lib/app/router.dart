// lib/app/router.dart

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// Views
import 'package:t0703/features/auth/view/login_screen.dart';
import 'package:t0703/features/auth/view/doctor_register_screen.dart';
import 'package:t0703/features/auth/view/find-Account_screen.dart';
import 'package:t0703/features/home/view/home_screen.dart'; // 환자 홈 화면
import 'package:t0703/features/doctor_portal/view/doctor_dashboard_screen.dart'; // 의료진 대시보드
import 'package:t0703/features/doctor_portal/view/telemedicine_detail_screen.dart'; // 진료 상세
import 'package:t0703/features/mypage/view/mypage_screen.dart'; // 마이페이지
import 'package:t0703/features/mypage/view/edit_profile_screen.dart'; // 프로필 수정

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login', // 초기 라우트 설정
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/doctor_register',
        builder: (context, state) => const DoctorRegisterScreen(),
      ),
      GoRoute(
        path: '/find-account',
        builder: (context, state) => const FindAccountScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(), // 환자 홈 화면 (의료진 앱에서는 사용되지 않을 수 있음)
      ),
      GoRoute(
        path: '/doctor-dashboard',
        builder: (context, state) => const DoctorDashboardScreen(), // 의사 대시보드
      ),
      GoRoute(
        path: '/telemedicine-detail/:requestId', // 진료 요청 ID를 파라미터로 받음
        builder: (context, state) {
          final requestId = state.pathParameters['requestId'];
          if (requestId == null) {
            return const Text('Error: Request ID not found'); // 오류 처리
          }
          return TelemedicineDetailScreen(requestId: requestId);
        },
      ),
      GoRoute(
        path: '/mypage',
        builder: (context, state) => const MyPageScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      // TODO: 추가 라우트 정의
    ],
    // 에러 발생 시 리다이렉트할 페이지 (예: 404 페이지)
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text('Error: ${state.error}')),
    ),
  );
}
