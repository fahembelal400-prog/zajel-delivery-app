import 'package:delevery_app/models/cart_item.dart';
import 'package:delevery_app/models/product.dart';
import 'package:delevery_app/models/store.dart';
import 'package:flutter/foundation.dart';

typedef StoreConflictResolver = Future<bool> Function({
  required String previousStoreName,
  required String newStoreName,
});

class CartManager extends ChangeNotifier {
  CartManager._();

  static final CartManager instance = CartManager._();

  static const double deliveryFee = 15;

  final List<CartItem> _items = <CartItem>[];
  String? _activeStoreId;
  String? _activeStoreName;

  List<CartItem> get items => List<CartItem>.unmodifiable(_items);

  bool get isEmpty => _items.isEmpty;

  String? get activeStoreId => _activeStoreId;
  String? get activeStoreName => _activeStoreName;

  int get totalQuantity =>
      _items.fold<int>(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.fold<double>(0, (sum, item) => sum + item.lineTotal);

  double get orderTotal => subtotal + deliveryFee;

  int quantityFor(String productId) {
    return _findItem(productId)?.quantity ?? 0;
  }

  Future<bool> requestAddProduct(
    Product product, {
    StoreConflictResolver? onStoreConflict,
  }) async {
    if (_hasStoreConflict(product.storeId)) {
      final resolver = onStoreConflict;
      if (resolver == null) {
        return false;
      }
      final approved = await resolver(
        previousStoreName: _activeStoreName!,
        newStoreName: storeNameFor(product.storeId),
      );
      if (!approved) {
        return false;
      }
      _clearItemsOnly();
    }

    _addProductInternal(product);
    return true;
  }

  void incrementQuantity(String productId) {
    final item = _findItem(productId);
    if (item == null) {
      return;
    }
    item.quantity++;
    notifyListeners();
  }

  void decrementQuantity(String productId) {
    final item = _findItem(productId);
    if (item == null) {
      return;
    }
    if (item.quantity <= 1) {
      removeItem(productId);
      return;
    }
    item.quantity--;
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    if (_items.isEmpty) {
      _activeStoreId = null;
      _activeStoreName = null;
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _activeStoreId = null;
    _activeStoreName = null;
    notifyListeners();
  }

  static String storeNameFor(String storeId) {
    for (final store in dummyStores) {
      if (store.id == storeId) {
        return store.name;
      }
    }
    return 'متجر';
  }

  bool _hasStoreConflict(String storeId) {
    return !isEmpty &&
        _activeStoreId != null &&
        _activeStoreId != storeId;
  }

  void _clearItemsOnly() {
    _items.clear();
    _activeStoreId = null;
    _activeStoreName = null;
    notifyListeners();
  }

  void _addProductInternal(Product product) {
    final existingIndex =
        _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }

    _activeStoreId ??= product.storeId;
    _activeStoreName ??= storeNameFor(product.storeId);
    notifyListeners();
  }

  CartItem? _findItem(String productId) {
    for (final item in _items) {
      if (item.product.id == productId) {
        return item;
      }
    }
    return null;
  }
}
