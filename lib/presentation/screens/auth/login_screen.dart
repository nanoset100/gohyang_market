import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/auth_service.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  String _selectedRegion = AppConfig.pilotRegions[0]['code']!;
  String _selectedRegionName = AppConfig.pilotRegions[0]['name']!;
  String _userType = 'both';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showError('이메일과 비밀번호를 입력해주세요');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await _authService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        if (_nameController.text.trim().isEmpty) {
          _showError('이름을 입력해주세요');
          setState(() => _isLoading = false);
          return;
        }
        await _authService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          regionCode: _selectedRegion,
          regionName: _selectedRegionName,
          userType: _userType,
        );
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              AppColors.primary.withValues(alpha: 0.05),
              AppColors.primaryLight.withValues(alpha: 0.1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 60),
                // 로고 및 브랜드 섹션
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: AppColors.premiumShadow,
                  ),
                  child: const Icon(Icons.eco_rounded, size: 64, color: AppColors.primary),
                ),
                const SizedBox(height: 24),
                Text(
                  AppConfig.appName,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: -1.0,
                  ),
                ),
                Text(
                  AppConfig.appDescription,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),

                // 로그인/회원가입 전환 제어기
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(AppColors.radiusM),
                  ),
                  child: Row(
                    children: [
                      _buildTabButton('로그인', _isLogin, () => setState(() => _isLogin = true)),
                      _buildTabButton('회원가입', !_isLogin, () => setState(() => _isLogin = false)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 입력 폼 섹션
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    children: [
                      _buildTextField(_emailController, '이메일', Icons.mail_outline_rounded),
                      const SizedBox(height: 16),
                      _buildTextField(_passwordController, '비밀번호', Icons.lock_outline_rounded, isObscure: true),
                      
                      if (!_isLogin) ...[
                        const SizedBox(height: 16),
                        _buildTextField(_nameController, '이름', Icons.person_outline_rounded),
                        const SizedBox(height: 16),
                        _buildTextField(_phoneController, '전화번호', Icons.phone_android_rounded, type: TextInputType.phone),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          value: _selectedRegion,
                          label: '활동 지역',
                          icon: Icons.location_on_outlined,
                          items: AppConfig.pilotRegions.map((r) => 
                            DropdownMenuItem(value: r['code'], child: Text('${r['province']} ${r['name']}'))
                          ).toList(),
                          onChanged: (v) {
                            final region = AppConfig.pilotRegions.firstWhere((r) => r['code'] == v);
                            setState(() {
                              _selectedRegion = v!;
                              _selectedRegionName = region['name']!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildDropdownField(
                          value: _userType,
                          label: '가입 목적',
                          icon: Icons.assignment_ind_outlined,
                          items: const [
                            DropdownMenuItem(value: 'seller', child: Text('판매자 (농어민)')),
                            DropdownMenuItem(value: 'buyer', child: Text('구매자')),
                            DropdownMenuItem(value: 'both', child: Text('판매 + 구매 모두')),
                          ],
                          onChanged: (v) => setState(() => _userType = v!),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 메인 액션 버튼
                Container(
                  width: double.infinity,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.primaryGradient),
                    borderRadius: BorderRadius.circular(AppColors.radiusM),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppColors.radiusM)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(_isLogin ? '로그인' : '회원가입 시작하기', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(height: 24),
                
                TextButton(
                  onPressed: () {}, // 비밀번호 찾기 등 추가 가능
                  child: Text(
                    _isLogin ? '계정 정보를 잊으셨나요?' : '이미 계정이 있으신가요?',
                    style: TextStyle(color: AppColors.textHint, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(AppColors.radiusM - 4),
            boxShadow: isSelected ? AppColors.premiumShadow : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isSelected ? AppColors.primary : AppColors.textHint,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isObscure = false, TextInputType type = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppColors.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textHint, fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: AppColors.primaryLight, size: 22),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppColors.radiusM), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildDropdownField({required String value, required String label, required IconData icon, required List<DropdownMenuItem<String>> items, required Function(String?) onChanged}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppColors.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textHint, fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: AppColors.primaryLight, size: 22),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppColors.radiusM), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
