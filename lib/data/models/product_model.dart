import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String sellerId;
  final String sellerName;
  final String regionCode;     // 시군구 코드 (예: sinan)
  final String regionName;     // 시군구 이름 (예: 신안군)
  final String name;           // 상품명
  final String description;    // 상품 설명
  final String category;       // 카테고리
  final int price;             // 가격 (원)
  final String unit;           // 단위 (1kg, 1박스 등)
  final List<String> imageUrls; // 상품 이미지 URL 목록
  final String? aiDescription; // AI가 생성한 설명
  final String? sellerStory;   // 판매자 이야기
  final String? phoneNumber;   // 직접 연락 번호
  final bool isAvailable;      // 판매 가능 여부
  final DateTime createdAt;
  final DateTime updatedAt;

  // 온톨로지 태그 (AI 자동 생성)
  final List<String> season;        // 제철 계절
  final List<int> bestMonths;       // 제철 월
  final List<String> pairsWith;     // 궁합 식품
  final List<String> recipes;       // 추천 요리
  final List<String> nutrition;     // 영양소
  final List<String> healthBenefits; // 건강 효과
  final String? storage;            // 보관법
  final List<String> keywords;      // 검색 키워드

  ProductModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.regionCode,
    required this.regionName,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.unit,
    required this.imageUrls,
    this.aiDescription,
    this.sellerStory,
    this.phoneNumber,
    this.isAvailable = true,
    required this.createdAt,
    required this.updatedAt,
    this.season = const [],
    this.bestMonths = const [],
    this.pairsWith = const [],
    this.recipes = const [],
    this.nutrition = const [],
    this.healthBenefits = const [],
    this.storage,
    this.keywords = const [],
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      regionCode: data['regionCode'] ?? '',
      regionName: data['regionName'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      price: data['price'] ?? 0,
      unit: data['unit'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      aiDescription: data['aiDescription'],
      sellerStory: data['sellerStory'],
      phoneNumber: data['phoneNumber'],
      isAvailable: data['isAvailable'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      season: List<String>.from(data['season'] ?? []),
      bestMonths: List<int>.from((data['bestMonths'] ?? []).map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)),
      pairsWith: List<String>.from(data['pairsWith'] ?? []),
      recipes: List<String>.from(data['recipes'] ?? []),
      nutrition: List<String>.from(data['nutrition'] ?? []),
      healthBenefits: List<String>.from(data['healthBenefits'] ?? []),
      storage: data['storage'],
      keywords: List<String>.from(data['keywords'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sellerId': sellerId,
      'sellerName': sellerName,
      'regionCode': regionCode,
      'regionName': regionName,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'unit': unit,
      'imageUrls': imageUrls,
      'aiDescription': aiDescription,
      'sellerStory': sellerStory,
      'phoneNumber': phoneNumber,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'season': season,
      'bestMonths': bestMonths,
      'pairsWith': pairsWith,
      'recipes': recipes,
      'nutrition': nutrition,
      'healthBenefits': healthBenefits,
      'storage': storage,
      'keywords': keywords,
    };
  }
}
