import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import '../../../core/constants/colors.dart';
import '../../../data/models/order_model.dart';
import '../../../data/services/order_service.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _orderService = OrderService();
  List<OrderModel> _myOrders = [];
  List<OrderModel> _receivedOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final myOrders = await _orderService.getMyOrders();
      final receivedOrders = await _orderService.getReceivedOrders();
      if (mounted) {
        setState(() {
          _myOrders = myOrders;
          _receivedOrders = receivedOrders;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('주문 관리'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: '내 주문 (${_myOrders.length})'),
            Tab(text: '받은 주문 (${_receivedOrders.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(_myOrders, isSeller: false),
                _buildOrderList(_receivedOrders, isSeller: true),
              ],
            ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, {required bool isSeller}) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              isSeller ? '받은 주문이 없습니다' : '주문 내역이 없습니다',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) => _buildOrderCard(orders[i], isSeller: isSeller),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, {required bool isSeller}) {
    final statusColor = _getStatusColor(order.status);
    final formattedPrice = order.totalPrice.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    final dateStr =
        '${order.createdAt.month}/${order.createdAt.day} ${order.createdAt.hour}:${order.createdAt.minute.toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 상단: 상태 + 날짜
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  dateStr,
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // 상품 정보
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: order.productImageUrl.isNotEmpty
                      ? Image.network(order.productImageUrl,
                          width: 60, height: 60, fit: BoxFit.cover)
                      : Container(
                          width: 60, height: 60, color: Colors.grey[200]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.productName,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        '${order.quantity}${order.productUnit} · $formattedPrice원',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        isSeller
                            ? '주문자: ${order.buyerName}'
                            : '판매자: ${order.sellerName}',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 배송지 + 메시지
          if (isSeller) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(order.buyerAddress,
                            style: const TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                  if (order.buyerMessage != null &&
                      order.buyerMessage!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.message,
                            size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text('"${order.buyerMessage}"',
                              style: const TextStyle(
                                  fontSize: 13, fontStyle: FontStyle.italic)),
                        ),
                      ],
                    ),
                  ],
                  Row(
                    children: [
                      const Icon(Icons.payment,
                          size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        order.paymentMethod == 'bank' ? '계좌이체' : '착불',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // 판매자: 상태 변경 버튼
          if (isSeller && order.status != OrderStatus.completed && order.status != OrderStatus.cancelled) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (order.buyerPhone.isNotEmpty)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _callBuyer(order.buyerPhone),
                        icon: const Icon(Icons.phone, size: 18),
                        label: const Text('전화'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                  if (order.buyerPhone.isNotEmpty)
                    const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(order),
                      child: Text(_getNextStatusText(order.status)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 구매자: 전화하기
          if (!isSeller && order.sellerPhone.isNotEmpty && order.status != OrderStatus.completed && order.status != OrderStatus.cancelled) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _callBuyer(order.sellerPhone),
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('판매자에게 전화'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.shipping:
        return AppColors.primary;
      case OrderStatus.completed:
        return Colors.grey;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _getNextStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return '주문 확인';
      case OrderStatus.confirmed:
        return '배송 시작';
      case OrderStatus.shipping:
        return '배송 완료';
      default:
        return '';
    }
  }

  Future<void> _updateStatus(OrderModel order) async {
    OrderStatus? nextStatus;
    switch (order.status) {
      case OrderStatus.pending:
        nextStatus = OrderStatus.confirmed;
        break;
      case OrderStatus.confirmed:
        nextStatus = OrderStatus.shipping;
        break;
      case OrderStatus.shipping:
        nextStatus = OrderStatus.completed;
        break;
      default:
        return;
    }

    await _orderService.updateOrderStatus(order.id, nextStatus);
    _loadOrders();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${order.productName} → ${nextStatus == OrderStatus.confirmed ? "주문 확인" : nextStatus == OrderStatus.shipping ? "배송중" : "배송 완료"}'),
        ),
      );
    }
  }

  void _callBuyer(String phone) async {
    final url = Uri.parse('tel:$phone');
    if (await launcher.canLaunchUrl(url)) {
      await launcher.launchUrl(url);
    }
  }
}
