import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  pending,    // 주문 요청
  confirmed,  // 판매자 확인
  shipping,   // 배송중
  completed,  // 완료
  cancelled,  // 취소
}

class OrderModel {
  final String id;
  final String productId;
  final String productName;
  final String productImageUrl;
  final int productPrice;
  final String productUnit;
  final String sellerId;
  final String sellerName;
  final String sellerPhone;
  final String buyerId;
  final String buyerName;
  final String buyerPhone;
  final String buyerAddress;
  final String? buyerMessage;
  final int quantity;
  final int totalPrice;
  final String paymentMethod; // 'bank' | 'cod' (착불)
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.productPrice,
    required this.productUnit,
    required this.sellerId,
    required this.sellerName,
    required this.sellerPhone,
    required this.buyerId,
    required this.buyerName,
    required this.buyerPhone,
    required this.buyerAddress,
    this.buyerMessage,
    required this.quantity,
    required this.totalPrice,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return '주문 요청';
      case OrderStatus.confirmed:
        return '주문 확인';
      case OrderStatus.shipping:
        return '배송중';
      case OrderStatus.completed:
        return '배송 완료';
      case OrderStatus.cancelled:
        return '취소됨';
    }
  }

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      productImageUrl: data['productImageUrl'] ?? '',
      productPrice: data['productPrice'] ?? 0,
      productUnit: data['productUnit'] ?? '',
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      sellerPhone: data['sellerPhone'] ?? '',
      buyerId: data['buyerId'] ?? '',
      buyerName: data['buyerName'] ?? '',
      buyerPhone: data['buyerPhone'] ?? '',
      buyerAddress: data['buyerAddress'] ?? '',
      buyerMessage: data['buyerMessage'],
      quantity: data['quantity'] ?? 1,
      totalPrice: data['totalPrice'] ?? 0,
      paymentMethod: data['paymentMethod'] ?? 'bank',
      status: OrderStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'productPrice': productPrice,
      'productUnit': productUnit,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerPhone': sellerPhone,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'buyerPhone': buyerPhone,
      'buyerAddress': buyerAddress,
      'buyerMessage': buyerMessage,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
