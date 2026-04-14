import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';
import '../../../data/services/order_service.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;
  final ProductService _productService = ProductService();
  final OrderService _orderService = OrderService();

  ProductDetailScreen({super.key, required this.product});

  bool get _isOwner =>
      FirebaseAuth.instance.currentUser?.uid == product.sellerId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 상품 이미지
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: _isOwner
                ? [
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditDialog(context);
                        } else if (value == 'delete') {
                          _showDeleteDialog(context);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('상품 수정'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('상품 삭제', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ]
                : null,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product_image_${product.id}',
                child: product.imageUrls.isNotEmpty
                    ? Image.network(
                        product.imageUrls[0],
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[100],
                        child: Icon(Icons.eco_rounded,
                            size: 80, color: AppColors.primary.withValues(alpha: 0.1)),
                      ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 지역 태그
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${product.regionName} 직송',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 상품명
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 가격
                  Text(
                    '${product.price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원 / ${product.unit}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 판매자 정보 (프리미엄 카드)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppColors.radiusM),
                      boxShadow: AppColors.premiumShadow,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: AppColors.primaryGradient),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              product.sellerName.isNotEmpty
                                  ? product.sellerName[0]
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.sellerName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_rounded, size: 14, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${product.regionName} 명예 농어민',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // 전화 버튼
                        if (product.phoneNumber != null &&
                            product.phoneNumber!.isNotEmpty)
                          IconButton(
                            onPressed: () => _callSeller(product.phoneNumber!),
                            icon: const Icon(Icons.phone,
                                color: AppColors.primary),
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.1),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 한줄 이야기 (따옴표 디자인)
                  if (product.sellerStory != null &&
                      product.sellerStory!.isNotEmpty) ...[
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(AppColors.radiusM),
                            border: Border.all(color: AppColors.accent.withValues(alpha: 0.1), width: 1.5),
                          ),
                          child: Text(
                            product.sellerStory!,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0, left: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            color: AppColors.background, // Or use specific BG color
                            child: const Icon(Icons.format_quote_rounded, color: AppColors.accent, size: 28),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],

                  // 상품 설명
                  const Text(
                    '상품 소개',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  // === AI 상품 메타데이터 섹션 ===

                  // 제철 정보
                  if (product.season.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle('제철 시기', Icons.calendar_month),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.season.map((s) => _buildTag(
                        s,
                        Colors.orange.shade50,
                        Colors.orange.shade700,
                      )).toList(),
                    ),
                    if (product.bestMonths.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${product.bestMonths.map((m) => '${m}월').join(', ')}이 가장 맛있어요',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange.shade600,
                        ),
                      ),
                    ],
                  ],

                  // 궁합 식품
                  if (product.pairsWith.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle('함께 먹으면 좋아요', Icons.restaurant),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.pairsWith.map((p) => _buildTappableTag(
                        context,
                        p,
                        AppColors.primary.withValues(alpha: 0.1),
                        AppColors.primary,
                      )).toList(),
                    ),
                  ],

                  // 추천 요리
                  if (product.recipes.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle('추천 요리', Icons.soup_kitchen),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.recipes.map((r) => _buildTappableTag(
                        context,
                        r,
                        Colors.amber.shade50,
                        Colors.amber.shade800,
                      )).toList(),
                    ),
                  ],

                  // 영양 & 건강
                  if (product.nutrition.isNotEmpty || product.healthBenefits.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle('영양 & 건강', Icons.favorite),
                    const SizedBox(height: 8),
                    if (product.nutrition.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: product.nutrition.map((n) => _buildTag(
                          n,
                          Colors.green.shade50,
                          Colors.green.shade700,
                        )).toList(),
                      ),
                    if (product.healthBenefits.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...product.healthBenefits.map((h) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 16, color: Colors.green.shade600),
                            const SizedBox(width: 6),
                            Text(
                              h,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ],

                  // 보관법
                  if (product.storage != null && product.storage!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionTitle('보관법', Icons.inventory_2),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 18, color: Colors.blue.shade600),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              product.storage!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // 하단 고정 버튼
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 전화하기
              if (product.phoneNumber != null &&
                  product.phoneNumber!.isNotEmpty)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _callSeller(product.phoneNumber!),
                    icon: const Icon(Icons.phone),
                    label: const Text('전화하기'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              if (product.phoneNumber != null &&
                  product.phoneNumber!.isNotEmpty)
                const SizedBox(width: 12),
              // 주문하기
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.primaryGradient),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => _showOrderSheet(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('지금 바로 주문하기', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textPrimary),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTappableTag(BuildContext context, String text, Color bgColor, Color textColor) {
    return GestureDetector(
      onTap: () => _showRelatedProducts(context, text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: textColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
            ),
            const SizedBox(width: 4),
            Icon(Icons.search, size: 14, color: textColor),
          ],
        ),
      ),
    );
  }

  void _showRelatedProducts(BuildContext context, String keyword) async {
    // 현재 지역의 모든 상품에서 관련 상품 검색
    final allProducts = await _productService.getProductsByRegion(product.regionCode);
    final q = keyword.toLowerCase();
    final related = allProducts.where((p) {
      if (p.id == product.id) return false; // 현재 상품 제외
      return p.name.toLowerCase().contains(q) ||
          p.keywords.any((k) => k.toLowerCase().contains(q)) ||
          p.pairsWith.any((pw) => pw.toLowerCase().contains(q)) ||
          p.recipes.any((r) => r.toLowerCase().contains(q)) ||
          p.nutrition.any((n) => n.toLowerCase().contains(q)) ||
          p.healthBenefits.any((h) => h.toLowerCase().contains(q));
    }).toList();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '"$keyword" 관련 상품',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (related.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    '아직 "$keyword" 관련 상품이 없습니다.\n상품이 등록되면 여기에 표시됩니다!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
                  ),
                ),
              )
            else
              ...related.take(5).map((p) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: p.imageUrls.isNotEmpty
                      ? Image.network(p.imageUrls[0], width: 50, height: 50, fit: BoxFit.cover)
                      : Container(width: 50, height: 50, color: Colors.grey[200]),
                ),
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  '${p.price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원 / ${p.unit}',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)),
                  );
                },
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(text: product.price.toString());
    final descController = TextEditingController(text: product.description);
    final unitController = TextEditingController(text: product.unit);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('상품 수정', style: TextStyle(fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '상품명'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: '가격 (원)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(labelText: '단위 (예: 1kg)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: '상품 설명'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _productService.updateProduct(product.id, {
                'name': nameController.text.trim(),
                'price': int.tryParse(priceController.text.trim()) ?? product.price,
                'unit': unitController.text.trim(),
                'description': descController.text.trim(),
              });
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                Navigator.pop(context, true); // 목록 새로고침
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('상품이 수정되었습니다')),
                );
              }
            },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('상품 삭제', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('"${product.name}"을(를) 삭제하시겠습니까?\n삭제하면 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _productService.deleteProduct(product.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                Navigator.pop(context, true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('상품이 삭제되었습니다')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('삭제', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showOrderSheet(BuildContext context) {
    int quantity = 1;
    final addressController = TextEditingController();
    final messageController = TextEditingController();
    String paymentMethod = 'bank';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final totalPrice = product.price * quantity;
            final formattedTotal = totalPrice.toString().replaceAllMapped(
                RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

            return Padding(
              padding: EdgeInsets.only(
                left: 20, right: 20, top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '주문 요청',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 16),

                    // 상품 정보
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: product.imageUrls.isNotEmpty
                                ? Image.network(product.imageUrls[0],
                                    width: 60, height: 60, fit: BoxFit.cover)
                                : Container(width: 60, height: 60, color: Colors.grey[200]),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.name,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                Text(
                                  '${product.price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원 / ${product.unit}',
                                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 수량
                    const Text('수량', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        IconButton(
                          onPressed: quantity > 1
                              ? () => setModalState(() => quantity--)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          color: AppColors.primary,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$quantity ${product.unit}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          onPressed: () => setModalState(() => quantity++),
                          icon: const Icon(Icons.add_circle_outline),
                          color: AppColors.primary,
                        ),
                        const Spacer(),
                        Text(
                          '$formattedTotal원',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 배송지
                    const Text('배송지', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        hintText: '배송 받으실 주소를 입력하세요',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 결제 방법
                    const Text('결제 방법', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => paymentMethod = 'bank'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: paymentMethod == 'bank'
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: paymentMethod == 'bank'
                                      ? AppColors.primary
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.account_balance,
                                      color: paymentMethod == 'bank'
                                          ? AppColors.primary
                                          : Colors.grey),
                                  const SizedBox(height: 4),
                                  Text(
                                    '계좌이체',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: paymentMethod == 'bank'
                                          ? AppColors.primary
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => paymentMethod = 'cod'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: paymentMethod == 'cod'
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: paymentMethod == 'cod'
                                      ? AppColors.primary
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.local_shipping,
                                      color: paymentMethod == 'cod'
                                          ? AppColors.primary
                                          : Colors.grey),
                                  const SizedBox(height: 4),
                                  Text(
                                    '착불',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: paymentMethod == 'cod'
                                          ? AppColors.primary
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 메시지
                    const Text('판매자에게 메시지 (선택)',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: messageController,
                      decoration: InputDecoration(
                        hintText: '예: 단단한 걸로 골라주세요',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 주문 요청 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (addressController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('배송지를 입력해주세요')),
                            );
                            return;
                          }

                          try {
                            await _orderService.createOrder(
                              productId: product.id,
                              productName: product.name,
                              productImageUrl: product.imageUrls.isNotEmpty
                                  ? product.imageUrls[0]
                                  : '',
                              productPrice: product.price,
                              productUnit: product.unit,
                              sellerId: product.sellerId,
                              sellerName: product.sellerName,
                              sellerPhone: product.phoneNumber ?? '',
                              quantity: quantity,
                              buyerAddress: addressController.text.trim(),
                              paymentMethod: paymentMethod,
                              buyerMessage: messageController.text.trim().isEmpty
                                  ? null
                                  : messageController.text.trim(),
                            );

                            if (ctx.mounted) Navigator.pop(ctx);
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder: (dlgCtx) => AlertDialog(
                                  title: const Text('주문 요청 완료!',
                                      style: TextStyle(fontWeight: FontWeight.w700)),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${product.name} $quantity${product.unit}'),
                                      Text('총 $formattedTotal원',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary)),
                                      const SizedBox(height: 12),
                                      const Text(
                                        '판매자에게 주문이 전달되었습니다.\n곧 전화로 확인 연락이 올 거예요!',
                                        style: TextStyle(height: 1.5),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(dlgCtx),
                                      child: const Text('확인'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('주문 실패: $e')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          '$formattedTotal원 주문 요청',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
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

  void _callSeller(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
