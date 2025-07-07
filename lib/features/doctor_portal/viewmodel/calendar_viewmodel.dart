// lib/features/doctor_portal/viewmodel/calendar_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // isSameDay 함수 사용을 위해 임포트
import 'package:t0703/features/doctor_portal/model/appointment.dart';
// import 'package:t0703/core/api_service.dart'; // API 서비스 임포트 (가정)

class CalendarViewModel extends ChangeNotifier {
  final String baseUrl; // API 호출을 위한 기본 URL
  Map<DateTime, List<Appointment>> _appointments = {};
  bool _isLoading = false;
  String? _errorMessage;

  CalendarViewModel({required this.baseUrl});

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 특정 월의 진료 예약 데이터를 가져오는 메서드
  Future<void> fetchAppointments(int year, int intmonth) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ⭐ 실제 API 서비스 호출:
      // final response = await http.get(Uri.parse('$baseUrl/appointments?year=$year&month=$intmonth'));
      // List<Appointment> fetchedAppointments = (json.decode(response.body) as List).map((data) => Appointment.fromJson(data)).toList();

      // 가상 데이터 로드 (매월 다른 데이터 시뮬레이션)
      await Future.delayed(const Duration(seconds: 1));
      List<Appointment> fetchedAppointments = [];
      if (intmonth == 7 && year == 2025) { // 2025년 7월 데이터
        fetchedAppointments = [
          Appointment(id: 'app_001', patientName: '김민준', dateTime: DateTime.utc(2025, 7, 8, 10, 0), type: '비대면 진료', requestId: 'req_001'),
          Appointment(id: 'app_002', patientName: '이지은', dateTime: DateTime.utc(2025, 7, 8, 11, 30), type: '비대면 진료', requestId: 'req_002'),
          Appointment(id: 'app_003', patientName: '박찬호', dateTime: DateTime.utc(2025, 7, 10, 14, 0), type: '오프라인 진료'),
          Appointment(id: 'app_004', patientName: '최현우', dateTime: DateTime.utc(2025, 7, 15, 9, 0), type: '비대면 진료', requestId: 'req_003'),
          Appointment(id: 'app_005', patientName: '한지민', dateTime: DateTime.utc(2025, 7, 22, 16, 0), type: '오프라인 진료'),
          Appointment(id: 'app_006', patientName: '강동원', dateTime: DateTime.utc(2025, 7, 22, 17, 0), type: '비대면 진료', requestId: 'req_004'),
        ];
      } else if (intmonth == 8 && year == 2025) { // 2025년 8월 데이터
        fetchedAppointments = [
          Appointment(id: 'app_007', patientName: '정우성', dateTime: DateTime.utc(2025, 8, 5, 10, 0), type: '비대면 진료', requestId: 'req_005'),
          Appointment(id: 'app_008', patientName: '고소영', dateTime: DateTime.utc(2025, 8, 5, 11, 0), type: '오프라인 진료'),
        ];
      }
      // ... 다른 월 데이터

      _appointments = _groupAppointmentsByDay(fetchedAppointments);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Appointment 리스트를 DateTime 키를 가진 맵으로 그룹화
  Map<DateTime, List<Appointment>> _groupAppointmentsByDay(List<Appointment> appointments) {
    final Map<DateTime, List<Appointment>> grouped = {};
    for (var appt in appointments) {
      // 날짜 부분만 사용하여 그룹화 (시간은 무시)
      final day = DateTime.utc(appt.dateTime.year, appt.dateTime.month, appt.dateTime.day);
      if (grouped[day] == null) {
        grouped[day] = [];
      }
      grouped[day]!.add(appt);
    }
    // 각 날짜별로 시간 순으로 정렬
    grouped.forEach((key, value) {
      value.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    });
    return grouped;
  }

  // TableCalendar의 eventLoader에 전달될 함수
  List<Appointment> getAppointmentsForDay(DateTime day) {
    return _appointments[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }
}
