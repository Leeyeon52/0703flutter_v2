// lib/features/doctor_portal/model/appointment.dart

class Appointment {
  final String id;
  final String patientName;
  final DateTime dateTime;
  final String type; // 예: '비대면 진료', '오프라인 진료'
  final String? requestId; // 비대면 진료 신청과 연동될 경우 ID

  Appointment({
    required this.id,
    required this.patientName,
    required this.dateTime,
    required this.type,
    this.requestId,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] as String,
      patientName: json['patientName'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      type: json['type'] as String,
      requestId: json['requestId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientName': patientName,
      'dateTime': dateTime.toIso8601String(),
      'type': type,
      'requestId': requestId,
    };
  }
}
