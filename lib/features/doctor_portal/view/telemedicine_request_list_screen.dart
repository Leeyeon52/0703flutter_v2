// lib/features/doctor_portal/view/telemedicine_request_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t0703/features/doctor_portal/model/patient_request.dart';
import 'package:t0703/features/doctor_portal/view/telemedicine_detail_screen.dart';
import 'package:t0703/features/doctor_portal/viewmodel/telemedicine_request_list_viewmodel.dart'; // ViewModel 임포트

class TelemedicineRequestListScreen extends StatefulWidget {
  const TelemedicineRequestListScreen({super.key});

  @override
  State<TelemedicineRequestListScreen> createState() => _TelemedicineRequestListScreenState();
}

class _TelemedicineRequestListScreenState extends State<TelemedicineRequestListScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 로드 시 진료 신청 목록 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TelemedicineRequestListViewModel>(context, listen: false).fetchRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 검색 필드
          TextField(
            decoration: const InputDecoration(
              labelText: '환자 이름 또는 증상 검색',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              Provider.of<TelemedicineRequestListViewModel>(context, listen: false).setSearchKeyword(value);
            },
          ),
          const SizedBox(height: 16.0),

          // 상태별 필터링 드롭다운
          Consumer<TelemedicineRequestListViewModel>(
            builder: (context, viewModel, child) {
              return DropdownButtonFormField<String>(
                value: viewModel.selectedStatusFilter,
                decoration: const InputDecoration(
                  labelText: '상태별 필터링',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    viewModel.setSelectedStatusFilter(newValue);
                  }
                },
                items: <String>['전체', '신청됨', '대기 중', '답변 완료']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 16.0),

          // 진료 신청 목록
          Expanded(
            child: Consumer<TelemedicineRequestListViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (viewModel.errorMessage != null) {
                  return Center(child: Text('오류: ${viewModel.errorMessage}'));
                } else if (viewModel.filteredRequests.isEmpty) {
                  return const Center(child: Text('진료 신청이 없습니다.'));
                } else {
                  return ListView.builder(
                    itemCount: viewModel.filteredRequests.length,
                    itemBuilder: (context, index) {
                      final request = viewModel.filteredRequests[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: request.imageUrl != null && request.imageUrl!.isNotEmpty
                                ? Image.network(
                                    request.imageUrl!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                                  )
                                : Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.person, size: 40, color: Colors.grey),
                                  ),
                          ),
                          title: Text(
                            '${request.patientName} (${request.status})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('AI 요약: ${request.aiSummary ?? 'N/A'}', style: const TextStyle(fontSize: 13)),
                              Text('담당의: ${request.assignedDoctor ?? '미지정'}', style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TelemedicineDetailScreen(requestId: request.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
