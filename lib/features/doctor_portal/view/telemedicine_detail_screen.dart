// lib/features/doctor_portal/view/telemedicine_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t0703/features/doctor_portal/model/patient_request.dart';
import 'package:t0703/features/doctor_portal/viewmodel/telemedicine_detail_viewmodel.dart'; // ViewModel 임포트

class TelemedicineDetailScreen extends StatefulWidget {
  final String requestId;
  const TelemedicineDetailScreen({super.key, required this.requestId});

  @override
  State<TelemedicineDetailScreen> createState() => _TelemedicineDetailScreenState();
}

class _TelemedicineDetailScreenState extends State<TelemedicineDetailScreen> {
  final TextEditingController _doctorCommentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 화면 로드 시 상세 진료 정보 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TelemedicineDetailViewModel>(context, listen: false)
          .fetchPatientRequestDetail(widget.requestId)
          .then((_) {
        // 데이터 로드 후 AI 진단 코멘트를 컨트롤러에 설정
        final viewModel = Provider.of<TelemedicineDetailViewModel>(context, listen: false);
        if (viewModel.currentRequest != null) {
          _doctorCommentController.text = viewModel.currentRequest!.aiSummary ?? '';
        }
      });
    });
  }

  @override
  void dispose() {
    _doctorCommentController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _sendDiagnosisResult() async {
    final viewModel = Provider.of<TelemedicineDetailViewModel>(context, listen: false);
    if (viewModel.currentRequest == null) {
      _showSnack('진료 정보를 불러올 수 없습니다.');
      return;
    }

    // TODO: 드로잉 툴에서 수정된 병변 데이터 가져오기
    final updatedAiData = '수정된 병변 데이터 (좌표 등)'; // 실제 데이터로 대체

    final success = await viewModel.sendDiagnosisResult(
      widget.requestId,
      _doctorCommentController.text,
      updatedAiData,
    );

    if (success) {
      _showSnack('진단 결과가 환자에게 성공적으로 전송되었습니다.');
      // 선택적으로 이전 화면으로 돌아가기
      // Navigator.pop(context);
    } else {
      _showSnack(viewModel.errorMessage ?? '진단 결과 전송 실패');
    }
  }

  Future<void> _issuePrescription() async {
    final viewModel = Provider.of<TelemedicineDetailViewModel>(context, listen: false);
    if (viewModel.currentRequest == null) {
      _showSnack('진료 정보를 불러올 수 없습니다.');
      return;
    }

    // TODO: 처방전 작성 UI를 띄우고 데이터 입력 받기
    // 여기서는 간단히 처방전 발급 성공 메시지만 표시
    final success = await viewModel.issuePrescription(widget.requestId, '가상 처방 내용'); // 실제 처방 내용 전달

    if (success) {
      _showSnack('처방전이 발급되었습니다.');
    } else {
      _showSnack(viewModel.errorMessage ?? '처방전 발급 실패');
    }
  }

  Future<void> _scheduleAppointment() async {
    final viewModel = Provider.of<TelemedicineDetailViewModel>(context, listen: false);
    if (viewModel.currentRequest == null) {
      _showSnack('진료 정보를 불러올 수 없습니다.');
      return;
    }

    // TODO: 진료 예약 UI를 띄우고 날짜/시간 선택 받기
    // 여기서는 간단히 예약 성공 메시지만 표시
    final success = await viewModel.scheduleAppointment(
      widget.requestId,
      DateTime.now().add(const Duration(days: 7)), // 가상 예약 날짜
    );

    if (success) {
      _showSnack('진료 예약이 완료되었습니다.');
    } else {
      _showSnack(viewModel.errorMessage ?? '진료 예약 실패');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<TelemedicineDetailViewModel>(
          builder: (context, viewModel, child) {
            return Text(
              viewModel.currentRequest?.patientName != null
                  ? '${viewModel.currentRequest!.patientName} 환자 상세 진료'
                  : '상세 진료',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            );
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Consumer<TelemedicineDetailViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (viewModel.errorMessage != null) {
            return Center(child: Text('오류: ${viewModel.errorMessage}'));
          } else if (viewModel.currentRequest == null) {
            return const Center(child: Text('진료 정보를 찾을 수 없습니다.'));
          }

          final request = viewModel.currentRequest!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(context, '환자 기본 정보'),
                _buildInfoRow('이름', request.patientName),
                _buildInfoRow('환자 ID', request.patientId),
                // TODO: 실제 환자 모델에서 나이, 성별 등 정보 추가
                _buildInfoRow('상태', request.status),
                const SizedBox(height: 20),

                _buildSectionTitle(context, '문진 정보'),
                _buildInfoRow('주요 증상', request.symptom),
                _buildInfoRow('통증 정도 (리커트 척도)', request.likertScale),
                _buildInfoRow('환자 코멘트', request.patientComment),
                const SizedBox(height: 20),

                _buildSectionTitle(context, 'AI 분석 결과 확인 및 수정'),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: request.imageUrl != null && request.imageUrl!.isNotEmpty
                            ? Image.network(
                                request.imageUrl!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image, size: 100, color: Colors.grey),
                              )
                            : const Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                      ),
                      // TODO: AI가 표시한 병변 시각화 오버레이 (CustomPainter 또는 패키지 사용)
                      // TODO: 의료진이 병변을 직접 수정할 수 있는 드로잉 툴 UI
                      const Center(
                        child: Text(
                          'AI 이미지 + 드로잉 툴 영역 (개발 필요)',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _doctorCommentController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'AI 진단 코멘트 및 의사 보완/추가 입력',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _sendDiagnosisResult,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('진단 결과 전송', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _issuePrescription,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('처방전 발급', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _scheduleAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('진료 예약 연동', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }
}
