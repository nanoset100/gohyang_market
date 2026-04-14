import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';
import '../auth/login_screen.dart';
import '../seller/product_register_screen.dart';
import '../product/product_detail_screen.dart';
import '../order/order_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _productService = ProductService();
  String _regionName = '';
  String _userName = '';
  String _userType = '';
  List<ProductModel> _products = [];
  List<ProductModel> _allProducts = [];
  String? _selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _authService.getUserProfile();
      final regionCode = profile?['regionCode'] ?? 'sinan';
      final products = await _productService.getProductsByRegion(regionCode);

      if (mounted) {
        setState(() {
          _regionName = profile?['regionName'] ?? '신안군';
          _userName = profile?['name'] ?? '';
          _userType = profile?['userType'] ?? 'buyer';
          _allProducts = products;
          _products = products;
          _selectedCategory = null;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 프리미엄 상단 앱바 (Glassmorphism)
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              stretch: true,
              backgroundColor: Colors.white.withValues(alpha: 0.8),
              surfaceTintColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: Text(
                  '$_regionName ${AppConfig.appName}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                background: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.receipt_long, color: AppColors.textPrimary),
                  tooltip: '주문 관리',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrderListScreen()),
                  ).then((_) => _loadData()),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: AppColors.textPrimary),
                  onPressed: _logout,
                ),
                const SizedBox(width: 8),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 환영 카드 (프리미엄 그라데이션)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.primaryGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppColors.radiusL),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_userName님, 반갑습니다!',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(AppColors.radiusS),
                            ),
                            child: Text(
                              '오늘 $_regionName의 가장 신선한 소식을 확인하세요',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 검색바 (현대적인 플로팅 스타일)
                    GestureDetector(
                      onTap: () => _showSearchDialog(),
                      child: Hero(
                        tag: 'search_bar',
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppColors.radiusM),
                            boxShadow: AppColors.premiumShadow,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded, color: AppColors.primary, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                '무엇이든 검색해보세요 (상품, 효능, 요리...)',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textHint,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 카테고리 섹션
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '카테고리별 탐색',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: AppConfig.categories.length,
                        physics: const BouncingScrollPhysics(),
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (_, i) {
                          final cat = AppConfig.categories[i];
                          final isSelected = _selectedCategory == cat['key'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_selectedCategory == cat['key']) {
                                  _selectedCategory = null;
                                  _products = _allProducts;
                                } else {
                                  _selectedCategory = cat['key'];
                                  _products = _allProducts
                                      .where((p) => p.category == cat['key'])
                                      .toList();
                                }
                              });
                            },
                            child: Column(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: isSelected ? [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ] : AppColors.premiumShadow,
                                  ),
                                  child: Center(
                                    child: Text(
                                      cat['icon']!,
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  cat['name']!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // AI 추천 섹션
                    _buildAiRecommendSection(),
                    const SizedBox(height: 32),

                    // 상품 목록 헤더
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedCategory != null
                                  ? '${AppConfig.categories.firstWhere((c) => c['key'] == _selectedCategory)['name']} 컬렉션'
                                  : '발굴된 고향의 맛',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              _selectedCategory != null
                                  ? '엄격하게 선별된 ${_products.length}개의 상품'
                                  : '$_regionName에서 갓 올라온 신선한 상품들',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        if (_selectedCategory != null)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategory = null;
                                _products = _allProducts;
                              });
                            },
                            child: const Text('전체보기', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (_products.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppColors.radiusM),
                          boxShadow: AppColors.premiumShadow,
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.eco_outlined, size: 64, color: AppColors.primary.withValues(alpha: 0.2)),
                            const SizedBox(height: 16),
                            const Text(
                              '아직 준비 중인 상품입니다',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text('조금만 기다려주시면 신선한 상품으로 찾아뵐게요',
                                style: TextStyle(fontSize: 13, color: AppColors.textHint)),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _products.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 20),
                        itemBuilder: (_, i) {
                          final product = _products[i];
                          return _buildProductCard(product);
                        },
                      ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 상품 등록 FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProductRegisterScreen(),
          ),
        ).then((_) => _loadData()),
        icon: const Icon(Icons.camera_alt, color: Colors.white),
        label: const Text(
          '상품 등록',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showSearchDialog() {
    final controller = TextEditingController();
    List<ProductModel> results = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void search(String query) {
              if (query.trim().isEmpty) {
                setModalState(() => results = []);
                return;
              }
              final q = query.trim().toLowerCase();
              setModalState(() {
                results = _allProducts.where((p) {
                  return p.name.toLowerCase().contains(q) ||
                      p.description.toLowerCase().contains(q) ||
                      p.category.toLowerCase().contains(q) ||
                      p.keywords.any((k) => k.toLowerCase().contains(q)) ||
                      p.recipes.any((r) => r.toLowerCase().contains(q)) ||
                      p.pairsWith.any((pw) => pw.toLowerCase().contains(q)) ||
                      p.healthBenefits.any((h) => h.toLowerCase().contains(q)) ||
                      p.nutrition.any((n) => n.toLowerCase().contains(q)) ||
                      p.season.any((s) => s.toLowerCase().contains(q));
                }).toList();
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: controller,
                        autofocus: true,
                        onChanged: search,
                        decoration: InputDecoration(
                          hintText: '상품명, 요리, 건강 효과로 검색',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: controller.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    controller.clear();
                                    search('');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                    // 빠른 검색 태그
                    if (results.isEmpty && controller.text.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '이런 걸 검색해보세요',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: ['양파', '혈관건강', '카레', '봄', '비타민']
                                  .map((tag) => GestureDetector(
                                        onTap: () {
                                          controller.text = tag;
                                          search(tag);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            tag,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    // 검색 결과
                    Expanded(
                      child: results.isEmpty && controller.text.isNotEmpty
                          ? Center(
                              child: Text(
                                '"${controller.text}" 검색 결과가 없습니다',
                                style: const TextStyle(color: AppColors.textSecondary),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: results.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (_, i) {
                                final p = results[i];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: p.imageUrls.isNotEmpty
                                        ? Image.network(p.imageUrls[0],
                                            width: 50, height: 50, fit: BoxFit.cover)
                                        : Container(width: 50, height: 50,
                                            color: Colors.grey[200]),
                                  ),
                                  title: Text(p.name,
                                      style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text(
                                    '${p.price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원 / ${p.unit}',
                                    style: const TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProductDetailScreen(product: p),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAiRecommendSection() {
    final now = DateTime.now();
    final currentMonth = now.month;
    final seasonalProducts = _allProducts
        .where((p) => p.bestMonths.contains(currentMonth))
        .toList();

    // 제철 상품이 없으면 전체 상품을 추천
    final recommendProducts = seasonalProducts.isNotEmpty
        ? seasonalProducts
        : _allProducts;
    final subtitle = seasonalProducts.isNotEmpty
        ? '${currentMonth}월 제철 상품 ${seasonalProducts.length}개'
        : '$_regionName 신선 상품 ${_allProducts.length}개';

    if (recommendProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accent.withValues(alpha: 0.05),
                AppColors.accentLight.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppColors.radiusL),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI 맞춤 제철 추천',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            subtitle,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: recommendProducts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (_, i) {
                    final p = recommendProducts[i];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: p),
                        ),
                      ),
                      child: Container(
                        width: 140,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppColors.radiusM),
                          boxShadow: AppColors.premiumShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppColors.radiusM)),
                                child: Stack(
                                  children: [
                                    p.imageUrls.isNotEmpty
                                        ? Image.network(p.imageUrls[0], width: 140, height: double.infinity, fit: BoxFit.cover)
                                        : Container(width: 140, color: Colors.grey[200]),
                                    Positioned(
                                      top: 8, left: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.6),
                                          borderRadius: BorderRadius.circular(AppColors.radiusS),
                                        ),
                                        child: const Text('New', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${p.price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppColors.radiusM),
          boxShadow: AppColors.premiumShadow,
        ),
        child: Row(
          children: [
            // 상품 이미지 (Hero 적용)
            Hero(
              tag: 'product_image_${product.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppColors.radiusM),
                  bottomLeft: Radius.circular(AppColors.radiusM),
                ),
                child: product.imageUrls.isNotEmpty
                    ? Image.network(
                        product.imageUrls[0],
                        width: 130,
                        height: 130,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 130,
                        height: 130,
                        color: Colors.grey[100],
                        child: Icon(Icons.eco_rounded, color: AppColors.primary.withValues(alpha: 0.2), size: 40),
                      ),
              ),
            ),
            // 상품 정보
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.tagVegetable,
                            borderRadius: BorderRadius.circular(AppColors.radiusS),
                          ),
                          child: Text(
                            product.regionName,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (product.season.isNotEmpty)
                          Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textHint),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            product.price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          const Text(
                            '원',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            ' / ${product.unit}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textHint,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
