import 'dart:convert';
import 'dart:math';

import 'package:delevery_app/models/order_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckoutFormCache {
  const CheckoutFormCache({
    this.customerName = '',
    this.street = '',
    this.building = '',
    this.notes = '',
    this.phone = '',
  });

  final String customerName;
  final String street;
  final String building;
  final String notes;
  final String phone;

  bool get isEmpty =>
      customerName.isEmpty &&
      street.isEmpty &&
      building.isEmpty &&
      notes.isEmpty &&
      phone.isEmpty;

  String get displayName =>
      customerName.trim().isEmpty ? 'ضيف زاجل' : customerName.trim();

  String get displayPhone =>
      phone.trim().isEmpty ? 'أضف رقم هاتفك' : phone.trim();

  String get deliveryAddressSummary {
    final streetLine = street.trim();
    final buildingLine = building.trim();
    if (streetLine.isEmpty && buildingLine.isEmpty) {
      return 'أضف عنوان التوصيل';
    }
    if (buildingLine.isEmpty) {
      return streetLine;
    }
    if (streetLine.isEmpty) {
      return buildingLine;
    }
    return '$streetLine • $buildingLine';
  }

  CheckoutFormCache copyWith({
    String? customerName,
    String? street,
    String? building,
    String? notes,
    String? phone,
  }) {
    return CheckoutFormCache(
      customerName: customerName ?? this.customerName,
      street: street ?? this.street,
      building: building ?? this.building,
      notes: notes ?? this.notes,
      phone: phone ?? this.phone,
    );
  }
}

class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  static const _guestDeviceIdKey = 'guest_device_id';
  static const _ordersKey = 'guest_orders_json';
  static const _profileCustomerNameKey = 'profile_customer_name';
  static const _checkoutStreetKey = 'checkout_street';
  static const _checkoutBuildingKey = 'checkout_building';
  static const _checkoutNotesKey = 'checkout_notes';
  static const _checkoutPhoneKey = 'checkout_phone';
  static const _recentSearchesKey = 'recent_searches_json';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    await ensureGuestDeviceId();
  }

  Future<String> ensureGuestDeviceId() async {
    final prefs = _requirePrefs();
    final existing = prefs.getString(_guestDeviceIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final generated = _generateGuestDeviceId();
    await prefs.setString(_guestDeviceIdKey, generated);
    return generated;
  }

  String? get guestDeviceId => _prefs?.getString(_guestDeviceIdKey);

  Future<List<OrderModel>> loadOrders({String? guestDeviceId}) async {
    final prefs = _requirePrefs();
    final raw = prefs.getString(_ordersKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }

      final orders = <OrderModel>[];
      for (final entry in decoded) {
        if (entry is! Map) {
          continue;
        }
        final order = OrderModel.fromJson(Map<String, dynamic>.from(entry));
        if (guestDeviceId == null ||
            guestDeviceId.isEmpty ||
            order.guestDeviceId == guestDeviceId) {
          orders.add(order);
        }
      }
      return orders;
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveOrders(List<OrderModel> orders) async {
    final prefs = _requirePrefs();
    final encoded = jsonEncode(orders.map((order) => order.toJson()).toList());
    await prefs.setString(_ordersKey, encoded);
  }

  Future<CheckoutFormCache> loadCheckoutCache() async {
    final prefs = _requirePrefs();
    return CheckoutFormCache(
      customerName: prefs.getString(_profileCustomerNameKey) ?? '',
      street: prefs.getString(_checkoutStreetKey) ?? '',
      building: prefs.getString(_checkoutBuildingKey) ?? '',
      notes: prefs.getString(_checkoutNotesKey) ?? '',
      phone: prefs.getString(_checkoutPhoneKey) ?? '',
    );
  }

  Future<void> saveCheckoutCache(CheckoutFormCache cache) async {
    final prefs = _requirePrefs();
    await prefs.setString(_profileCustomerNameKey, cache.customerName.trim());
    await prefs.setString(_checkoutStreetKey, cache.street);
    await prefs.setString(_checkoutBuildingKey, cache.building);
    await prefs.setString(_checkoutNotesKey, cache.notes);
    await prefs.setString(_checkoutPhoneKey, cache.phone);
  }

  Future<List<String>> loadRecentSearches() async {
    final prefs = _requirePrefs();
    final raw = prefs.getString(_recentSearchesKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }
      return decoded
          .whereType<String>()
          .map((entry) => entry.trim())
          .where((entry) => entry.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> addRecentSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final prefs = _requirePrefs();
    final current = await loadRecentSearches();
    final updated = <String>[
      trimmed,
      ...current.where((entry) => entry != trimmed),
    ].take(8).toList();
    await prefs.setString(_recentSearchesKey, jsonEncode(updated));
  }

  Future<void> clearRecentSearches() async {
    final prefs = _requirePrefs();
    await prefs.remove(_recentSearchesKey);
  }

  static String shortUserIdLabel(String? guestDeviceId) {
    if (guestDeviceId == null || guestDeviceId.isEmpty) {
      return 'ID: #USR-0000';
    }
    final compact = guestDeviceId.replaceAll('-', '');
    final suffix = compact.length >= 4
        ? compact.substring(compact.length - 4).toUpperCase()
        : compact.toUpperCase();
    return 'ID: #USR-$suffix';
  }

  SharedPreferences _requirePrefs() {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError('StorageService.init() must be called before use.');
    }
    return prefs;
  }

  String _generateGuestDeviceId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    String hex(int value) => value.toRadixString(16).padLeft(2, '0');
    final buffer = StringBuffer();
    for (var i = 0; i < 16; i++) {
      if (i == 4 || i == 6 || i == 8 || i == 10) {
        buffer.write('-');
      }
      buffer.write(hex(bytes[i]));
    }
    return buffer.toString();
  }
}
