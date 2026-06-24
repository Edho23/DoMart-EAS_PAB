import 'package:firebase_auth/firebase_auth.dart';
import '../../core/network/realtime_api_client.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final RealtimeApiClient _apiClient;
  OrderRepositoryImpl(this._apiClient);

  Future<String?> _token() => FirebaseAuth.instance.currentUser?.getIdToken() ?? Future.value(null);

  @override
  Future<String> createOrder(AppOrder order) async {
    final token = await _token();
    final result = await _apiClient.post('orders', order.toMap(), idToken: token);
    return result['name'] as String;
  }

  @override
  Future<List<AppOrder>> getOrdersByUser(String userId) async {
    final token = await _token();
    final data = await _apiClient.get('orders', idToken: token);
    final orders = <AppOrder>[];
    if (data is Map) {
      data.forEach((key, value) {
        final map = Map<String, dynamic>.from(value as Map);
        if (map['userId'] == userId) {
          orders.add(_mapToOrder(key, map));
        }
      });
    }
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  @override
  Future<List<AppOrder>> getAllOrders() async {
    final token = await _token();
    final data = await _apiClient.get('orders', idToken: token);
    final orders = <AppOrder>[];
    if (data is Map) {
      data.forEach((key, value) {
        orders.add(_mapToOrder(key, Map<String, dynamic>.from(value as Map)));
      });
    }
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    final token = await _token();
    await _apiClient.patch('orders/$orderId', {'status': status}, idToken: token);
  }

  AppOrder _mapToOrder(String id, Map<String, dynamic> map) {
    return AppOrder(
      id: id,
      userId: map['userId'],
      items: (map['items'] as List).map((e) {
        final m = Map<String, dynamic>.from(e as Map);
        return OrderItem(
          productId: m['productId'], name: m['name'],
          price: (m['price'] as num).toDouble(), qty: m['qty'] as int,
        );
      }).toList(),
      total: (map['total'] as num).toDouble(),
      status: map['status'],
      paymentMethod: map['paymentMethod'],
      createdAt: map['createdAt'],
    );
  }
}