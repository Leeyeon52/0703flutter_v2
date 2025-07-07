// lib/features/mypage/viewmodel/userinfo_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:t0703/features/auth/model/user.dart';

class UserInfoViewModel extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserInfoViewModel();

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage; // errorMessage getter 추가

  void loadUser(User user) {
    _user = user;
    notifyListeners();
  }

  // 사용자 정보 업데이트 메서드
  Future<bool> updateProfile({
    String? name,
    String? gender,
    String? birth,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 실제 API 호출 로직 (백엔드로 업데이트된 정보 전송)
      // 예: await ApiService().updateUserProfile(_user!.uid, name, gender, birth, phone);
      await Future.delayed(const Duration(seconds: 1)); // 시뮬레이션

      if (_user != null) {
        _user = User(
          uid: _user!.uid,
          email: _user!.email,
          name: name ?? _user!.name,
          isDoctor: _user!.isDoctor,
          gender: gender ?? _user!.gender,
          birth: birth ?? _user!.birth,
          phone: phone ?? _user!.phone,
        );
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
