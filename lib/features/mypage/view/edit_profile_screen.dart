// lib/features/mypage/view/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:t0703/features/mypage/viewmodel/userinfo_viewmodel.dart';
import 'package:t0703/features/auth/model/user.dart'; // User 모델 임포트

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _birthController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController; // userId 대신 email 사용
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserInfoViewModel>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _selectedGender = user?.gender ?? 'M';
    _birthController = TextEditingController(text: user?.birth ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _emailController = TextEditingController(text: user?.email ?? ''); // user.email 사용
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
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

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      _showSnack('모든 필드를 올바르게 입력해주세요.');
      return;
    }

    final userInfoViewModel = context.read<UserInfoViewModel>();

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
        },
      );

      final success = await userInfoViewModel.updateProfile(
        name: _nameController.text.trim(),
        gender: _selectedGender,
        birth: _birthController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (success) {
        _showSnack('프로필이 성공적으로 업데이트되었습니다!');
        context.pop(); // 이전 화면으로 돌아가기
      } else {
        _showSnack(userInfoViewModel.errorMessage ?? '프로필 업데이트 실패');
      }
    } catch (e) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      _showSnack('프로필 업데이트 중 오류 발생: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserInfoViewModel>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '프로필 수정',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Container(
        color: Colors.grey[50],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('기본 정보'),
                _buildTextFormField(
                  controller: _nameController,
                  labelText: '이름',
                  icon: Icons.person_outline,
                  validator: (value) => value!.isEmpty ? '이름을 입력해주세요.' : null,
                ),
                const SizedBox(height: 20),
                _buildGenderSelection(),
                const SizedBox(height: 20),
                _buildTextFormField(
                  controller: _birthController,
                  labelText: '생년월일 (YYYY-MM-DD)',
                  icon: Icons.calendar_today_outlined,
                  keyboardType: TextInputType.datetime,
                  validator: (value) {
                    if (value!.isEmpty) return '생년월일을 입력해주세요.';
                    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                      return '유효한 날짜 형식(YYYY-MM-DD)을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextFormField(
                  controller: _phoneController,
                  labelText: '전화번호',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.isEmpty ? '전화번호를 입력해주세요.' : null,
                ),
                const SizedBox(height: 30),
                _buildSectionTitle('계정 정보'),
                _buildTextFormField(
                  controller: _emailController,
                  labelText: '아이디 (이메일)',
                  icon: Icons.email_outlined,
                  readOnly: true, // 이메일은 수정 불가
                  validator: (value) => null, // 읽기 전용이므로 유효성 검사 필요 없음
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      '프로필 업데이트',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      readOnly: readOnly,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
      validator: validator,
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 8.0),
          child: Text(
            '성별',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedGender,
            decoration: const InputDecoration(
              border: InputBorder.none, // DropdownButtonFormField 자체의 border 제거
              isDense: true,
              contentPadding: EdgeInsets.zero,
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
        ),
      ],
    );
  }
}
