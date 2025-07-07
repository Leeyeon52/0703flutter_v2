// lib/features/doctor_portal/view/doctor_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:t0703/features/doctor_portal/view/telemedicine_request_list_screen.dart';
import 'package:t0703/features/doctor_portal/view/calendar_screen.dart';
import 'package:go_router/go_router.dart'; // GoRouter 임포트 추가

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('의사 대시보드', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              context.go('/mypage'); // 마이페이지로 이동
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).tabBarTheme.labelColor,
          unselectedLabelColor: Theme.of(context).tabBarTheme.unselectedLabelColor,
          indicatorColor: Theme.of(context).tabBarTheme.indicatorColor,
          tabs: const [
            Tab(text: '비대면 진료 신청', icon: Icon(Icons.receipt_long)),
            Tab(text: '진료 캘린더', icon: Icon(Icons.calendar_today)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TelemedicineRequestListScreen(), // 비대면 진료 신청 목록
          CalendarScreen(),                // 진료 캘린더
        ],
      ),
    );
  }
}
