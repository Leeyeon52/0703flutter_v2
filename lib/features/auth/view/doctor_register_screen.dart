// lib/features/auth/view/doctor_register_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:t0703/features/auth/viewmodel/auth_viewmodel.dart';

class DoctorRegisterScreen extends StatefulWidget {
  const DoctorRegisterScreen({super.key});

  @override
  State<DoctorRegisterScreen> createState() => _DoctorRegisterScreenState();
}

class _DoctorRegisterScreenState extends State<DoctorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final bool _isDoctor = true; // 의료진 전용이므로 기본값은 true로 고정
  String? _selectedGender;
  final _birthController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _birthController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(15),
        backgroundColor: Colors.blueGrey[700],
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      _showSnack('모든 필드를 올바르게 입력해주세요.');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnack('비밀번호가 일치하지 않습니다.');
      return;
    }

    // 성별이 선택되었는지 추가 확인
    if (_selectedGender == null) {
      _showSnack('성별을 선택해주세요.');
      return;
    }

    final authViewModel = context.read<AuthViewModel>();

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
        },
      );

      // 이메일 중복 확인
      final emailExists = await authViewModel.checkEmailDuplicate(_emailController.text.trim());
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // 로딩 인디케이터 숨기기
      }

      if (emailExists) {
        _showSnack('이미 존재하는 이메일입니다. 다른 이메일을 사용해주세요.');
        return;
      }

      // 회원가입 시도
      final error = await authViewModel.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
        _isDoctor,
        gender: _selectedGender,
        birth: _birthController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // 로딩 인디케이터 숨기기
      }

      if (error == null) {
        _showSnack('의료진 계정 회원가입 성공!');
        context.go('/login'); // 회원가입 성공 시 로그인 화면으로 이동
      } else {
        _showSnack('회원가입 실패: $error');
      }
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // 로딩 인디케이터 숨기기
      }
      _showSnack('회원가입 중 예기치 않은 오류가 발생했습니다: ${e.toString()}');
    }
  }

  // 생년월일 입력 시 하이픈을 자동으로 추가하는 함수
  void _formatDate(String text) {
    String cleanedText = text.replaceAll('-', ''); // 기존 하이픈 제거
    String formattedText = '';

    if (cleanedText.length > 8) {
      cleanedText = cleanedText.substring(0, 8); // 8자리까지만 허용 (YYYYMMDD)
    }

    if (cleanedText.length > 4) {
      formattedText += cleanedText.substring(0, 4);
      formattedText += '-';
      cleanedText = cleanedText.substring(4);
    }
    if (cleanedText.length > 2) {
      formattedText += cleanedText.substring(0, 2);
      formattedText += '-';
      cleanedText = cleanedText.substring(2);
    }
    formattedText += cleanedText;

    // 커서 위치 조정
    final int newSelectionStart = formattedText.length;
    _birthController.value = TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newSelectionStart),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '의료진 회원가입',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_hospital_outlined,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '의료진 계정 생성',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: '아이디 (이메일)',
                      hintText: 'example@example.com',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이메일을 입력해주세요';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return '유효한 이메일 형식을 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '비밀번호',
                      hintText: '비밀번호를 입력해주세요',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 입력해주세요';
                      }
                      if (value.length < 6) {
                        return '비밀번호는 6자 이상이어야 합니다.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '비밀번호 확인',
                      hintText: '비밀번호를 다시 입력해주세요',
                      prefixIcon: Icon(Icons.lock_reset_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 다시 입력해주세요';
                      }
                      if (value != _passwordController.text) {
                        return '비밀번호가 일치하지 않습니다.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: '이름',
                      hintText: '이름을 입력해주세요',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '이름을 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  // 성별 선택 드롭다운
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: '성별',
                      prefixIcon: Icon(Icons.people_alt_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'M', child: Text('남성')),
                      DropdownMenuItem(value: 'F', child: Text('여성')),
                      DropdownMenuItem(value: 'O', child: Text('기타')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    validator: (value) => value == null ? '성별을 선택해주세요.' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _birthController,
                    keyboardType: TextInputType.number, // 숫자 키보드 사용
                    decoration: const InputDecoration(
                      labelText: '생년월일 (YYYY-MM-DD)',
                      hintText: 'YYYY-MM-DD',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    onChanged: _formatDate, // 추가된 부분
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '생년월일을 입력해주세요.';
                      }
                      // 하이픈이 자동으로 추가되므로 10자리를 확인
                      if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                        return '유효한 날짜 형식(YYYY-MM-DD)을 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: '전화번호',
                      hintText: '010-1234-5678',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '전화번호를 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _register,
                      child: const Text('회원가입'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      '이미 계정이 있으신가요? 로그인',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}