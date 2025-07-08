// lib/features/auth/viewmodel/auth_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:t0703/features/auth/model/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthViewModel extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  final String baseUrl;

  AuthViewModel({required this.baseUrl});

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  // 사용자 로그인
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      print('Login API Status Code: ${response.statusCode}');
      print('Login API Response Body: ${response.body}'); // 디버깅을 위해 추가

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // 백엔드 응답이 {'user': {...}} 형태인지, 아니면 {...} 형태인지 확인 필요
        // 현재는 {'user': {...}} 형태를 가정합니다.
        if (data['user'] != null) {
          _currentUser = User.fromJson(data['user']);
          print('Parsed User Data: ${_currentUser?.toJson()}'); // 디버깅을 위해 추가
          _setLoading(false);
          return true;
        } else {
          _setErrorMessage('로그인 응답에 사용자 정보가 없습니다.');
          _setLoading(false);
          return false;
        }
      } else {
        _setErrorMessage('로그인 실패: ${response.body}');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setErrorMessage('네트워크 오류 또는 서버 응답 문제: $e');
      _setLoading(false);
      return false;
    }
  }

  // 사용자 회원가입
  // gender, birth, phone 파라미터를 추가했습니다.
  Future<String?> register(
    String email,
    String password,
    String name,
    bool isDoctor, {
    String? gender, // <--- 추가된 파라미터
    String? birth,  // <--- 추가된 파라미터
    String? phone,  // <--- 추가된 파라미터
  }) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'name': name,
          'is_doctor': isDoctor,
          'gender': gender, // <--- 백엔드로 전송할 데이터에 추가
          'birth': birth,   // <--- 백엔드로 전송할 데이터에 추가
          'phone': phone,   // <--- 백엔드로 전송할 데이터에 추가
        }),
      );

      print('Register API Status Code: ${response.statusCode}');
      print('Register API Response Body: ${response.body}'); // 디버깅을 위해 추가


      if (response.statusCode == 201) {
        _setLoading(false);
        return null; // 성공
      } else {
        final errorMsg = json.decode(response.body)['message'] ?? '회원가입 실패';
        _setErrorMessage(errorMsg);
        _setLoading(false);
        return errorMsg;
      }
    } catch (e) {
      _setErrorMessage('네트워크 오류 또는 서버 응답 문제: $e');
      _setLoading(false);
      return e.toString();
    }
  }

  // 이메일 중복 확인 (새로 추가)
  Future<bool> checkEmailDuplicate(String email) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/check_email_duplicate'), // 백엔드 중복 확인 엔드포인트
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      print('Duplicate Check API Status Code: ${response.statusCode}');
      print('Duplicate Check API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['exists'] as bool; // 백엔드 응답에 'exists': true/false가 있다고 가정
      } else {
        _setErrorMessage('이메일 중복 확인 실패: ${response.body}');
        return true; // 오류 발생 시 중복으로 간주하여 회원가입 진행 방지
      }
    } catch (e) {
      _setErrorMessage('네트워크 오류 또는 서버 응답 문제: $e');
      return true; // 네트워크 오류 시 중복으로 간주
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }


  // 사용자 계정 삭제
  Future<String?> deleteUser(String email, String password) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete_account'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        _currentUser = null; // 계정 삭제 성공 시 현재 사용자 정보 초기화
        _setLoading(false);
        return null; // 성공
      } else {
        final errorMsg = json.decode(response.body)['message'] ?? '계정 삭제 실패';
        _setErrorMessage(errorMsg);
        _setLoading(false);
        return errorMsg;
      }
    } catch (e) {
      _setErrorMessage('네트워크 오류 또는 서버 응답 문제: $e');
      _setLoading(false);
      return e.toString();
    }
  }

  // 로그아웃
  void logout() {
    _currentUser = null;
    _setErrorMessage(null);
    notifyListeners();
  }
}