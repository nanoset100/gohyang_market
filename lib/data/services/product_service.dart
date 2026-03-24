import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/product_model.dart';

class ProductService {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  /// 상품 등록
  Future<String> createProduct({
    required String name,
    required String description,
    required String category,
    required int price,
    required String unit,
    required String regionCode,
    required String regionName,
    required List<File> images,
    String? aiDescription,
    String? sellerStory,
    String? phoneNumber,
    Map<String, dynamic>? ontologyTags,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('로그인이 필요합니다');

    // 사용자 이름 가져오기
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final sellerName = userDoc.data()?['name'] ?? '판매자';

    // 이미지 업로드
    final imageUrls = <String>[];
    for (int i = 0; i < images.length; i++) {
      final ref = _storage
          .ref()
          .child('products/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_$i.jpg');
      await ref.putFile(images[i]);
      final url = await ref.getDownloadURL();
      imageUrls.add(url);
    }

    // Firestore에 상품 저장
    final docRef = await _firestore.collection('products').add({
      'sellerId': user.uid,
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
      'isAvailable': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      // 온톨로지 태그 (AI 자동 생성)
      'season': ontologyTags?['season'] ?? [],
      'bestMonths': ontologyTags?['bestMonths'] ?? [],
      'pairsWith': ontologyTags?['pairsWith'] ?? [],
      'recipes': ontologyTags?['recipes'] ?? [],
      'nutrition': ontologyTags?['nutrition'] ?? [],
      'healthBenefits': ontologyTags?['healthBenefits'] ?? [],
      'storage': ontologyTags?['storage'],
      'keywords': ontologyTags?['keywords'] ?? [],
    });

    return docRef.id;
  }

  /// 지역별 상품 목록
  Future<List<ProductModel>> getProductsByRegion(String regionCode) async {
    final snapshot = await _firestore
        .collection('products')
        .where('regionCode', isEqualTo: regionCode)
        .limit(20)
        .get();

    final products = snapshot.docs
        .map((d) => ProductModel.fromFirestore(d))
        .where((p) => p.isAvailable)
        .toList();
    products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return products;
  }

  /// 카테고리별 상품 목록
  Future<List<ProductModel>> getProductsByCategory(
      String regionCode, String category) async {
    final snapshot = await _firestore
        .collection('products')
        .where('regionCode', isEqualTo: regionCode)
        .where('category', isEqualTo: category)
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((d) => ProductModel.fromFirestore(d)).toList();
  }

  /// 내 상품 목록 (판매자용)
  Future<List<ProductModel>> getMyProducts() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await _firestore
        .collection('products')
        .where('sellerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((d) => ProductModel.fromFirestore(d)).toList();
  }

  /// 상품 상세
  Future<ProductModel?> getProduct(String productId) async {
    final doc = await _firestore.collection('products').doc(productId).get();
    if (!doc.exists) return null;
    return ProductModel.fromFirestore(doc);
  }

  /// 상품 수정
  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _firestore.collection('products').doc(productId).update(data);
  }

  /// 상품 삭제
  Future<void> deleteProduct(String productId) async {
    // 이미지도 삭제
    final doc = await _firestore.collection('products').doc(productId).get();
    if (doc.exists) {
      final imageUrls = List<String>.from(doc.data()?['imageUrls'] ?? []);
      for (final url in imageUrls) {
        try {
          await _storage.refFromURL(url).delete();
        } catch (_) {}
      }
    }
    await _firestore.collection('products').doc(productId).delete();
  }
}
