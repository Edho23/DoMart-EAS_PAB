import '../entities/order.dart';

abstract class OrderRepository {
  Future<String> createOrder(AppOrder order);
  Future<List<AppOrder>> getOrdersByUser(String userId);
  
  // Fitur baru khusus Seller
  Future<List<AppOrder>> getAllOrders(); 
  Future<void> updateOrderStatus(String orderId, String status); 
}