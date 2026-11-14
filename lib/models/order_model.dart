import 'package:delevery_app/models/order_tracking.dart';

class OrderLineItem {
  const OrderLineItem({
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
  });

  final String productId;
  final String name;
  final double unitPrice;
  final int quantity;

  double get lineTotal => unitPrice * quantity;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'unitPrice': unitPrice,
        'quantity': quantity,
      };

  factory OrderLineItem.fromJson(Map<String, dynamic> json) {
    return OrderLineItem(
      productId: json['productId'] as String,
      name: json['name'] as String,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }
}

class OrderModel {
  const OrderModel({
    required this.orderId,
    required this.guestDeviceId,
    required this.storeName,
    required this.itemsCount,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    required this.status,
    required this.trackingStep,
    required this.dateTime,
    required this.items,
    required this.deliveryAddress,
    required this.phone,
  });

  final String orderId;
  final String guestDeviceId;
  final String storeName;
  final int itemsCount;
  final double subtotal;
  final double deliveryFee;
  final double totalAmount;
  final String status;
  final String trackingStep;
  final DateTime dateTime;
  final List<OrderLineItem> items;
  final String deliveryAddress;
  final String phone;

  OrderModel copyWith({
    String? status,
    String? trackingStep,
  }) {
    return OrderModel(
      orderId: orderId,
      guestDeviceId: guestDeviceId,
      storeName: storeName,
      itemsCount: itemsCount,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      totalAmount: totalAmount,
      status: status ?? this.status,
      trackingStep: trackingStep ?? this.trackingStep,
      dateTime: dateTime,
      items: items,
      deliveryAddress: deliveryAddress,
      phone: phone,
    );
  }

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'guestDeviceId': guestDeviceId,
        'storeName': storeName,
        'itemsCount': itemsCount,
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'totalAmount': totalAmount,
        'status': status,
        'trackingStep': trackingStep,
        'dateTime': dateTime.toIso8601String(),
        'items': items.map((item) => item.toJson()).toList(),
        'deliveryAddress': deliveryAddress,
        'phone': phone,
      };

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'];
    final items = <OrderLineItem>[];
    if (itemsJson is List) {
      for (final entry in itemsJson) {
        if (entry is Map<String, dynamic>) {
          items.add(OrderLineItem.fromJson(entry));
        } else if (entry is Map) {
          items.add(OrderLineItem.fromJson(Map<String, dynamic>.from(entry)));
        }
      }
    }

    final legacyStatus = json['status'] as String;
    final trackingStep = resolveTrackingStep(
      trackingStep: json['trackingStep'] as String?,
      legacyStatus: legacyStatus,
    );

    return OrderModel(
      orderId: json['orderId'] as String,
      guestDeviceId: (json['guestDeviceId'] as String?) ?? '',
      storeName: json['storeName'] as String,
      itemsCount: json['itemsCount'] as int,
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: legacyStatus,
      trackingStep: trackingStep,
      dateTime: DateTime.parse(json['dateTime'] as String),
      items: items,
      deliveryAddress: json['deliveryAddress'] as String,
      phone: json['phone'] as String,
    );
  }
}
