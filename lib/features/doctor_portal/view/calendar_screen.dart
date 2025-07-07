// lib/features/doctor_portal/view/calendar_screen.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // isSameDay 함수 사용을 위해 임포트
import 'package:provider/provider.dart';
import 'package:t0703/features/doctor_portal/model/appointment.dart';
import 'package:t0703/features/doctor_portal/view/telemedicine_detail_screen.dart';
import 'package:t0703/features/doctor_portal/viewmodel/calendar_viewmodel.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // 화면 로드 시 초기 캘린더 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CalendarViewModel>(context, listen: false).fetchAppointments(_focusedDay.year, _focusedDay.month);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer<CalendarViewModel>(
          builder: (context, viewModel, child) {
            return TableCalendar<Appointment>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _showDailyPatientList(context, selectedDay, viewModel.getAppointmentsForDay(selectedDay));
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                // 월 변경 시 데이터 다시 로드
                viewModel.fetchAppointments(focusedDay.year, focusedDay.month);
              },
              eventLoader: viewModel.getAppointmentsForDay, // ViewModel의 메서드 사용
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      right: 1,
                      bottom: 1,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          '${events.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonShowsNext: false,
                titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(color: Colors.blue.shade100, shape: BoxShape.circle),
                selectedDecoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                markerDecoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              ),
            );
          },
        ),
        const SizedBox(height: 8.0),
        // 로딩 또는 에러 메시지 표시
        Consumer<CalendarViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const CircularProgressIndicator();
            } else if (viewModel.errorMessage != null) {
              return Text('오류: ${viewModel.errorMessage}');
            }
            return const SizedBox.shrink(); // 데이터 로드 완료 시 아무것도 표시 안 함
          },
        ),
      ],
    );
  }

  void _showDailyPatientList(BuildContext context, DateTime day, List<Appointment> appointments) {
    if (appointments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${day.toIso8601String().split('T')[0]} 에는 진료 신청이 없습니다.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${day.toIso8601String().split('T')[0]} 진료 목록',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Divider(),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    return ListTile(
                      title: Text('${appointment.patientName} (${appointment.type})'),
                      subtitle: Text(
                        '${appointment.dateTime.hour.toString().padLeft(2, '0')}:'
                        '${appointment.dateTime.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.pop(bc); // 모달 닫기
                        // 실제 환자 ID 또는 요청 ID를 기반으로 상세 화면 이동
                        if (appointment.requestId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TelemedicineDetailScreen(requestId: appointment.requestId!),
                            ),
                          );
                        } else {
                          // 비대면 진료 신청이 아닌 일반 진료 예약인 경우 처리
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('이 예약은 상세 진료 화면으로 연결되지 않습니다.')),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
