import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/colors.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/services/product_service.dart';

/// 상품 등록 화면
/// 핵심 UX: 사진 한 장 → AI 분석 → 자동 입력 → 등록 완료
class ProductRegisterScreen extends StatefulWidget {
  const ProductRegisterScreen({super.key});

  @override
  State<ProductRegisterScreen> createState() => _ProductRegisterScreenState();
}

class _ProductRegisterScreenState extends State<ProductRegisterScreen> {
  final _authService = AuthService();
  final _productService = ProductService();
  final _picker = ImagePicker();

  // 입력 컨트롤러
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitController = TextEditingController();
  final _storyController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _imageFile;
  String _category = 'vegetable';
  bool _isAnalyzing = false;
  bool _isSubmitting = false;
  bool _aiCompleted = false;
  String? _regionCode;
  String? _regionName;
  Map<String, dynamic>? _ontologyTags;

  @override
  void initState() {
    super.initState();
    _loadRegion();
  }

  Future<void> _loadRegion() async {
    _regionCode = await _authService.getSavedRegionCode();
    _regionName = await _authService.getSavedRegionName();
    final profile = await _authService.getUserProfile();
    if (profile != null && profile['phone'] != null) {
      _phoneController.text = profile['phone'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _storyController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// 카메라 또는 갤러리에서 사진 선택
  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() {
      _imageFile = File(picked.path);
      _aiCompleted = false;
    });

    // 사진 선택 즉시 AI 분석 시작
    _analyzeWithAI();
  }

  /// AI로 상품 사진 분석
  Future<void> _analyzeWithAI() async {
    if (_imageFile == null) return;

    setState(() => _isAnalyzing = true);

    try {
      final result = await AIService.analyzeProductImage(_imageFile!);

      if (mounted) {
        setState(() {
          _nameController.text = result['name'] ?? '';
          _descController.text = result['description'] ?? '';
          _category = result['category'] ?? 'other';
          _priceController.text = (result['suggestedPrice'] ?? '').toString();
          _unitController.text = result['unit'] ?? '';
          _storyController.text = result['story'] ?? '';
          _aiCompleted = true;

          // 온톨로지 태그 저장
          _ontologyTags = {
            'season': result['season'] ?? [],
            'bestMonths': result['bestMonths'] ?? [],
            'pairsWith': result['pairsWith'] ?? [],
            'recipes': result['recipes'] ?? [],
            'nutrition': result['nutrition'] ?? [],
            'healthBenefits': result['healthBenefits'] ?? [],
            'storage': result['storage'],
            'keywords': result['keywords'] ?? [],
          };
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI가 상품 정보를 만들었습니다! 확인 후 수정해주세요'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI 분석 실패: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  /// 상품 등록
  Future<void> _submit() async {
    if (_imageFile == null) {
      _showError('상품 사진을 찍어주세요');
      return;
    }
    if (_nameController.text.trim().isEmpty) {
      _showError('상품명을 입력해주세요');
      return;
    }
    if (_priceController.text.trim().isEmpty) {
      _showError('가격을 입력해주세요');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _productService.createProduct(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        category: _category,
        price: int.tryParse(_priceController.text.trim()) ?? 0,
        unit: _unitController.text.trim(),
        regionCode: _regionCode ?? 'sinan',
        regionName: _regionName ?? '신안군',
        images: [_imageFile!],
        aiDescription: _descController.text.trim(),
        sellerStory: _storyController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        ontologyTags: _ontologyTags,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('상품이 등록되었습니다!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('등록 실패: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
      appBar: AppBar(
        title: const Text('상품 등록'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // STEP 1: 사진 촬영
            const Text(
              '1단계: 사진을 찍어주세요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'AI가 사진을 보고 상품 정보를 자동으로 만들어드립니다',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),

            // 사진 영역
            GestureDetector(
              onTap: () => _showImageSourceDialog(),
              child: Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: _imageFile != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(
                              _imageFile!,
                              width: double.infinity,
                              height: 250,
                              fit: BoxFit.cover,
                            ),
                          ),
                          if (_isAnalyzing)
                            Container(
                              width: double.infinity,
                              height: 250,
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                      color: Colors.white),
                                  SizedBox(height: 16),
                                  Text(
                                    'AI가 분석 중입니다...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt,
                              size: 60, color: AppColors.primary),
                          SizedBox(height: 12),
                          Text(
                            '여기를 눌러 사진을 찍어주세요',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '카메라 또는 갤러리에서 선택',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),

            // STEP 2: AI 결과 확인 & 수정
            if (_aiCompleted || _nameController.text.isNotEmpty) ...[
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  const Text(
                    '2단계: 확인하고 수정하세요',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  if (_aiCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'AI 자동입력',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // 상품명
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '상품명',
                  hintText: '예: 신안 천일염',
                ),
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              // 카테고리
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: '카테고리'),
                items: AppConfig.categories
                    .map((c) => DropdownMenuItem(
                          value: c['key'],
                          child: Text('${c['icon']} ${c['name']}'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 12),

              // 가격 & 단위
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: '가격 (원)',
                        hintText: '15000',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: '단위',
                        hintText: '1kg',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 상품 설명
              TextField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: '상품 설명',
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 12),

              // 한줄 이야기
              TextField(
                controller: _storyController,
                decoration: const InputDecoration(
                  labelText: '한줄 이야기 (선택)',
                  hintText: '이 상품의 매력 포인트',
                ),
              ),
              const SizedBox(height: 12),

              // 연락처
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: '연락처',
                  hintText: '010-0000-0000',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),

              // 등록 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('상품 등록하기',
                          style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '사진 선택',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt,
                    color: AppColors.primary, size: 32),
                title: const Text('카메라로 촬영',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('지금 바로 상품 사진을 찍어요'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.photo_library,
                    color: AppColors.accent, size: 32),
                title: const Text('갤러리에서 선택',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('이미 찍어둔 사진을 선택해요'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
