// lib/features/doctor_portal/model/patient_request.dart

class PatientRequest {
  final String id;
  final String patientName;
  final String status; // 예: '신청됨', '대기 중', '답변 완료'
  final String? imageUrl; // 첨부 이미지 썸네일 URL
  final String? aiSummary; // AI 예비 진단 결과 요약
  final String? assignedDoctor; // 담당의 (지정된 경우)
  final String patientId; // 환자 ID (상세 진료 화면에서 사용)
  final String symptom; // 환자 문진 정보 - 증상
  final String likertScale; // 환자 문진 정보 - 리커트 척도
  final String patientComment; // 환자 문진 정보 - 코멘트

  PatientRequest({
    required this.id,
    required this.patientName,
    required this.status,
    this.imageUrl,
    this.aiSummary,
    this.assignedDoctor,
    required this.patientId,
    required this.symptom,
    required this.likertScale,
    required this.patientComment,
  });

  // JSON 또는 Map에서 PatientRequest 객체를 생성하는 팩토리 생성자
  factory PatientRequest.fromJson(Map<String, dynamic> json) {
    return PatientRequest(
      id: json['id'] as String,
      patientName: json['patientName'] as String,
      status: json['status'] as String,
      imageUrl: json['imageUrl'] as String?,
      aiSummary: json['aiSummary'] as String?,
      assignedDoctor: json['assignedDoctor'] as String?,
      patientId: json['patientId'] as String,
      symptom: json['symptom'] as String,
      likertScale: json['likertScale'] as String,
      patientComment: json['patientComment'] as String,
    );
  }

  // PatientRequest 객체를 JSON 또는 Map으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'status': status,
      'imageUrl': imageUrl,
      'aiSummary': aiSummary,
      'assignedDoctor': assignedDoctor,
      'patientId': patientId,
      'symptom': symptom,
      'likertScale': likertScale,
      'patientComment': patientComment,
    };
  }
}
