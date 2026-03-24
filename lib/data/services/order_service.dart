import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';

class OrderService {
  final _firestore = FirebaseFirestore.instance;

  /// 주문 요청
  Future<String> createOrder({
    required String productId,
    required String productName,
    required String productImageUrl,
    required int productPrice,
    required String productUnit,
    required String sellerId,
    required String sellerName,
    required String sellerPhone,
    required int quantity,
    required String buyerAddress,
    required String paymentMethod,
    String? buyerMessage,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('로그인이 필요합니다');

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data() ?? {};

    final docRef = await _firestore.collection('orders').add({
      'productId': productId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'productPrice': productPrice,
      'productUnit': productUnit,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerPhone': sellerPhone,
      'buyerId': user.uid,
      'buyerName': userData['name'] ?? '',
      'buyerPhone': userData['phone'] ?? '',
      'buyerAddress': buyerAddress,
      'buyerMessage': buyerMessage,
      'quantity': quantity,
      'totalPrice': productPrice * quantity,
      'paymentMethod': paymentMethod,
      'status': OrderStatus.pending.name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// 내가 주문한 목록 (구매자)
  Future<List<OrderModel>> getMyOrders() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await _firestore
        .collection('orders')
        .where('buyerId', isEqualTo: uid)
        .get();

    final orders = snapshot.docs.map((d) => OrderModel.fromFirestore(d)).toList();
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  /// 내가 받은 주문 목록 (판매자)
  Future<List<OrderModel>> getReceivedOrders() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: uid)
        .get();

    final orders = snapshot.docs.map((d) => OrderModel.fromFirestore(d)).toList();
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  /// 주문 상태 변경 (판매자용)
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
