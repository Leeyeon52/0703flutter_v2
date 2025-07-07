// lib/features/doctor_portal/viewmodel/telemedicine_request_list_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:t0703/features/doctor_portal/model/patient_request.dart';
// import 'package:t0703/core/api_service.dart'; // API 서비스 임포트 (가정)

class TelemedicineRequestListViewModel extends ChangeNotifier {
  final String baseUrl; // API 호출을 위한 기본 URL
  List<PatientRequest> _allRequests = [];
  String _selectedStatusFilter = '전체';
  String _searchKeyword = '';
  bool _isLoading = false;
  String? _errorMessage;

  TelemedicineRequestListViewModel({required this.baseUrl});

  // 필터링된 진료 신청 목록 반환
  List<PatientRequest> get filteredRequests {
    return _allRequests.where((request) {
      final statusMatch = _selectedStatusFilter == '전체' || request.status == _selectedStatusFilter;
      final searchMatch = request.patientName.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
          (request.aiSummary?.toLowerCase().contains(_searchKeyword.toLowerCase()) ?? false) ||
          request.symptom.toLowerCase().contains(_searchKeyword.toLowerCase());
      return statusMatch && searchMatch;
    }).toList();
  }

  String get selectedStatusFilter => _selectedStatusFilter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 진료 신청 목록을 가져오는 메서드 (실제로는 API 서비스에서 데이터를 가져옴)
  Future<void> fetchRequests() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ⭐ API 서비스 호출 예시:
      // final response = await http.get(Uri.parse('$baseUrl/patient_requests'));
      // _allRequests = (json.decode(response.body) as List).map((data) => PatientRequest.fromJson(data)).toList();

      // 가상 데이터 로드
      await Future.delayed(const Duration(seconds: 1));
      _allRequests = [
        PatientRequest(
          id: 'req_001', patientName: '김민준', status: '신청됨',
          imageUrl: 'https://placehold.co/100x100/FF5733/FFFFFF?text=Oral1',
          aiSummary: '우측 어금니 충치 의심', assignedDoctor: '미지정',
          patientId: 'pat_001', symptom: '오른쪽 위 어금니 시림', likertScale: '매우 불편함', patientComment: '차가운 물 마실 때 특히 시려요.',
        ),
        PatientRequest(
          id: 'req_002', patientName: '이지은', status: '대기 중',
          imageUrl: 'https://placehold.co/100x100/33FF57/FFFFFF?text=Oral2',
          aiSummary: '잇몸 염증 가능성', assignedDoctor: '박닥터',
          patientId: 'pat_002', symptom: '잇몸이 붓고 피가 나요', likertScale: '약간 불편함', patientComment: '양치할 때 피가 자주 나요.',
        ),
        PatientRequest(
          id: 'req_003', patientName: '최현우', status: '답변 완료',
          imageUrl: 'https://placehold.co/100x100/3357FF/FFFFFF?text=Oral3',
          aiSummary: '사랑니 발치 필요', assignedDoctor: '김닥터',
          patientId: 'pat_003', symptom: '사랑니 주변 통증', likertScale: '보통', patientComment: '음식물이 끼고 아파요.',
        ),
        PatientRequest(
          id: 'req_004', patientName: '박서연', status: '신청됨',
          imageUrl: '', // 이미지 없는 경우
          aiSummary: '치아 깨짐', assignedDoctor: '미지정',
          patientId: 'pat_004', symptom: '앞니가 깨졌어요', likertScale: '매우 불편함', patientComment: '넘어져서 부딪혔어요.',
        ),
      ];
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 상태 필터 설정
  void setSelectedStatusFilter(String status) {
    _selectedStatusFilter = status;
    notifyListeners();
  }

  // 검색 키워드 설정
  void setSearchKeyword(String keyword) {
    _searchKeyword = keyword;
    notifyListeners();
  }
}
