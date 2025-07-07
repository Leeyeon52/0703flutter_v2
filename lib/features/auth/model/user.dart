// lib/features/auth/model/user.dart

class User {
  final String uid;
  final String email; // 로그인 아이디로 사용되는 이메일
  final String name;
  final bool isDoctor;
  final String? gender; // 추가: 성별
  final String? birth;  // 추가: 생년월일 (예: "YYYY-MM-DD")
  final String? phone;  // 추가: 전화번호

  User({
    required this.uid,
    required this.email,
    required this.name,
    this.isDoctor = false,
    this.gender,
    this.birth,
    this.phone,
  });

  // JSON 또는 Map에서 User 객체를 생성하는 팩토리 생성자
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      isDoctor: json['is_doctor'] as bool? ?? false, // ⭐ 'is_doctor'로 변경
      gender: json['gender'] as String?,
      birth: json['birth'] as String?,
      phone: json['phone'] as String?,
    );
  }

  // User 객체를 JSON 또는 Map으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'is_doctor': isDoctor, // ⭐ 'is_doctor'로 변경
      'gender': gender,
      'birth': birth,
      'phone': phone,
    };
  }
}
