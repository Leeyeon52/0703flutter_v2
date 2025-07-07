// lib/features/doctor_portal/viewmodel/telemedicine_detail_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:t0703/features/doctor_portal/model/patient_request.dart';

class TelemedicineDetailViewModel extends ChangeNotifier {
  final String baseUrl; // API 호출을 위한 기본 URL
  PatientRequest? _currentRequest;
  bool _isLoading = false;
  String? _errorMessage;

  TelemedicineDetailViewModel({required this.baseUrl});

  PatientRequest? get currentRequest => _currentRequest;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 특정 진료 신청의 상세 정보를 가져오는 메서드
  Future<void> fetchPatientRequestDetail(String requestId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ⭐ 실제 API 서비스 호출:
      // final response = await http.get(Uri.parse('$baseUrl/patient_requests/$requestId'));
      // _currentRequest = PatientRequest.fromJson(json.decode(response.body));

      // 가상 데이터 로드 (requestId에 따라 다른 데이터 반환)
      await Future.delayed(const Duration(seconds: 1));
      if (requestId == 'req_001') {
        _currentRequest = PatientRequest(
          id: 'req_001', patientName: '김민준', status: '신청됨',
          imageUrl: 'https://placehold.co/600x400/FF5733/FFFFFF?text=Oral+Image+1',
          aiSummary: '우측 상악 구치부 충치 가능성 높음. 정밀 진단 필요.', assignedDoctor: '미지정',
          patientId: 'pat_001', symptom: '오른쪽 위 어금니 시림', likertScale: '매우 불편함', patientComment: '차가운 물 마실 때 특히 시려요. 밤에 잠들기 힘들 때도 있어요.',
        );
      } else if (requestId == 'req_002') {
        _currentRequest = PatientRequest(
          id: 'req_002', patientName: '이지은', status: '대기 중',
          imageUrl: 'https://placehold.co/600x400/33FF57/FFFFFF?text=Oral+Image+2',
          aiSummary: '잇몸 염증 가능성. 치석 제거 및 잇몸 치료 권장.', assignedDoctor: '박닥터',
          patientId: 'pat_002', symptom: '잇몸이 붓고 피가 나요', likertScale: '약간 불편함', patientComment: '양치할 때 피가 자주 나고, 가끔 욱신거려요.',
        );
      } else if (requestId == 'req_003') {
        _currentRequest = PatientRequest(
          id: 'req_003', patientName: '최현우', status: '답변 완료',
          imageUrl: 'https://placehold.co/600x400/3357FF/FFFFFF?text=Oral+Image+3',
          aiSummary: '사랑니 발치 필요. 인접 치아에 영향 줄 수 있음.', assignedDoctor: '김닥터',
          patientId: 'pat_003', symptom: '사랑니 주변 통증', likertScale: '보통', patientComment: '음식물이 끼고 아파요. 턱이 뻐근해요.',
        );
      } else if (requestId == 'req_004') {
        _currentRequest = PatientRequest(
          id: 'req_004', patientName: '박서연', status: '신청됨',
          imageUrl: 'https://placehold.co/600x400/FF00FF/FFFFFF?text=Oral+Image+4',
          aiSummary: '앞니 파절. 레진 또는 크라운 치료 필요.', assignedDoctor: '미지정',
          patientId: 'pat_004', symptom: '앞니가 깨졌어요', likertScale: '매우 불편함', patientComment: '넘어져서 부딪혔어요. 보기에 안 좋아요.',
        );
      }
      else {
        _errorMessage = '진료 요청을 찾을 수 없습니다.';
        _currentRequest = null;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _currentRequest = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 진단 결과 전송 (의사 코멘트 및 AI 수정 데이터 포함)
  Future<bool> sendDiagnosisResult(String requestId, String doctorComment, String aiModifiedData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // ⭐ 실제 API 서비스 호출:
      // await ApiService().sendDiagnosis(requestId, doctorComment, aiModifiedData);
      await Future.delayed(const Duration(seconds: 1)); // 시뮬레이션

      // 성공 시, 현재 요청 상태 업데이트
      if (_currentRequest != null && _currentRequest!.id == requestId) {
        _currentRequest = PatientRequest(
          id: _currentRequest!.id,
          patientName: _currentRequest!.patientName,
          status: '답변 완료', // 상태 변경
          imageUrl: _currentRequest!.imageUrl,
          aiSummary: doctorComment, // 의사 코멘트로 AI 요약 업데이트
          assignedDoctor: _currentRequest!.assignedDoctor,
          patientId: _currentRequest!.patientId,
          symptom: _currentRequest!.symptom,
          likertScale: _currentRequest!.likertScale,
          patientComment: _currentRequest!.patientComment,
        );
      }
      return true;
    } catch (e) {
      _errorMessage = '진단 결과 전송 실패: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 처방전 발급
  Future<bool> issuePrescription(String requestId, String prescriptionContent) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // ⭐ 실제 API 서비스 호출:
      // await ApiService().issuePrescription(requestId, prescriptionContent);
      await Future.delayed(const Duration(seconds: 1)); // 시뮬레이션
      return true;
    } catch (e) {
      _errorMessage = '처방전 발급 실패: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 진료 예약 연동
  Future<bool> scheduleAppointment(String requestId, DateTime appointmentTime) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // ⭐ 실제 API 서비스 호출:
      // await ApiService().scheduleAppointment(requestId, appointmentTime);
      await Future.delayed(const Duration(seconds: 1)); // 시뮬레이션
      return true;
    } catch (e) {
      _errorMessage = '진료 예약 실패: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
