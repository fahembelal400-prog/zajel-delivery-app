import 'package:delevery_app/data/cart_manager.dart';
import 'package:delevery_app/models/cart_item.dart';
import 'package:delevery_app/models/order_model.dart';
import 'package:delevery_app/models/order_tracking.dart';
import 'package:delevery_app/models/store.dart';
import 'package:delevery_app/services/storage_service.dart';
import 'package:flutter/foundation.dart';

class OrdersManager extends ChangeNotifier {
  OrdersManager._();

  static final OrdersManager instance = OrdersManager._();

  final List<OrderModel> _orders = <OrderModel>[];
  bool _loaded = false;

  List<OrderModel> get orders => List<OrderModel>.unmodifiable(_orders);

  bool get isEmpty => _orders.isEmpty;

  Future<void> loadFromStorage() async {
    if (_loaded) {
      return;
    }
    final guestId =
        StorageService.instance.guestDeviceId ??
        await StorageService.instance.ensureGuestDeviceId();
    final storedOrders = await StorageService.instance.loadOrders(
      guestDeviceId: guestId,
    );
    _orders
      ..clear()
      ..addAll(storedOrders);
    _loaded = true;
    notifyListeners();
  }

  Future<void> placeOrder({
    required String deliveryAddress,
    required String phone,
    required CheckoutFormCache checkoutCache,
  }) async {
    final cart = CartManager.instance;
    if (cart.isEmpty) {
      return;
    }

    final guestId = await StorageService.instance.ensureGuestDeviceId();
    final storeName = _storeNameFor(cart.items.first.product.storeId);
    final lineItems = cart.items.map(_lineItemFromCartItem).toList();

    final order = OrderModel(
      orderId: DateTime.now().millisecondsSinceEpoch.toString(),
      guestDeviceId: guestId,
      storeName: storeName,
      itemsCount: cart.totalQuantity,
      subtotal: cart.subtotal,
      deliveryFee: CartManager.deliveryFee,
      totalAmount: cart.orderTotal,
      status: statusLabelForStep('placed'),
      trackingStep: 'placed',
      dateTime: DateTime.now(),
      items: lineItems,
      deliveryAddress: deliveryAddress,
      phone: phone,
    );

    _orders.insert(0, order);
    await StorageService.instance.saveOrders(_orders);
    await StorageService.instance.saveCheckoutCache(checkoutCache);
    notifyListeners();
  }

  OrderModel? findById(String orderId) {
    for (final order in _orders) {
      if (order.orderId == orderId) {
        return order;
      }
    }
    return null;
  }

  Future<bool> advanceTrackingStep(String orderId) async {
    final index = _orders.indexWhere((order) => order.orderId == orderId);
    if (index < 0) {
      return false;
    }

    final current = _orders[index];
    final nextStep = nextTrackingStep(current.trackingStep);
    if (nextStep == null) {
      return false;
    }

    _orders[index] = current.copyWith(
      trackingStep: nextStep,
      status: statusLabelForStep(nextStep),
    );
    await StorageService.instance.saveOrders(_orders);
    notifyListeners();
    return true;
  }

  void clear() {
    _orders.clear();
    _loaded = false;
    notifyListeners();
  }

  OrderLineItem _lineItemFromCartItem(CartItem item) {
    return OrderLineItem(
      productId: item.product.id,
      name: item.product.name,
      unitPrice: item.product.price,
      quantity: item.quantity,
    );
  }

  String _storeNameFor(String storeId) {
    for (final store in dummyStores) {
      if (store.id == storeId) {
        return store.name;
      }
    }
    return 'متجر';
  }
}
