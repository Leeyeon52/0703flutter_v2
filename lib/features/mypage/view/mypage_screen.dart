// lib/features/mypage/view/mypage_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:t0703/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:t0703/features/mypage/viewmodel/userinfo_viewmodel.dart';
import 'package:t0703/features/auth/model/user.dart'; // User 모델 임포트

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final _passwordController = TextEditingController();
  final _deleteFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
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

  Future<void> _confirmAccountDeletion(BuildContext context) async {
    final authViewModel = context.read<AuthViewModel>();
    final userInfoViewModel = context.read<UserInfoViewModel>();
    final user = userInfoViewModel.user;

    if (user == null) {
      _showSnack('로그인 정보가 없습니다.');
      return;
    }

    // 비밀번호 입력 다이얼로그
    String? enteredPassword;
    await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('계정 삭제 확인'),
          content: Form(
            key: _deleteFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('계정을 삭제하려면 비밀번호를 입력해주세요.'),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해주세요.';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    enteredPassword = value;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('삭제'),
              onPressed: () async {
                if (_deleteFormKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(enteredPassword);
                }
              },
            ),
          ],
        );
      },
    );

    if (enteredPassword != null) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
          },
        );

        // user.email 사용
        final error = await authViewModel.deleteUser(user.email, enteredPassword!);

        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        if (error == null) {
          _showSnack('계정이 성공적으로 삭제되었습니다.');
          context.go('/login'); // 로그인 화면으로 이동
        } else {
          _showSnack('계정 삭제 실패: $error');
        }
      } catch (e) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        _showSnack('계정 삭제 중 오류 발생: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userInfoViewModel = context.watch<UserInfoViewModel>();
    final user = userInfoViewModel.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '마이페이지',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(context, user),
              const SizedBox(height: 30),
              _buildSectionTitle('계정 정보'),
              _buildInfoRow('이메일', user?.email ?? '로그인 필요'),
              _buildInfoRow('이름', user?.name ?? '로그인 필요'),
              _buildInfoRow('성별', user?.gender ?? '미입력'),
              _buildInfoRow('생년월일', user?.birth ?? '미입력'),
              _buildInfoRow('전화번호', user?.phone ?? '미입력'),
              const SizedBox(height: 30),
              _buildSectionTitle('계정 관리'),
              _buildAccountManagementButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, User? user) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blueAccent.withOpacity(0.2),
            child: const Icon(Icons.person, size: 60, color: Colors.blueAccent),
          ),
          const SizedBox(height: 15),
          Text(
            user?.name ?? '게스트',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
          Text(
            user?.email ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountManagementButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.go('/edit-profile'),
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text('프로필 수정'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _confirmAccountDeletion(context),
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            label: const Text('계정 삭제', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<AuthViewModel>().logout();
              context.go('/login');
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('로그아웃', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}
