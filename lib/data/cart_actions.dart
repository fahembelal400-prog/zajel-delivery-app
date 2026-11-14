import 'package:delevery_app/data/cart_manager.dart';
import 'package:delevery_app/models/order_model.dart';
import 'package:delevery_app/models/product.dart';
import 'package:delevery_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

Product? productById(String productId) {
  for (final product in dummyProducts) {
    if (product.id == productId) {
      return product;
    }
  }
  return null;
}

Future<bool> reorderOrderToCart(BuildContext context, OrderModel order) async {
  if (order.items.isEmpty) {
    return false;
  }
  final cart = CartManager.instance;
  for (final line in order.items) {
    final product = productById(line.productId);
    if (product == null) {
      continue;
    }
    final added = await addProductToCart(context, product);
    if (!added) {
      return false;
    }
    while (cart.quantityFor(product.id) < line.quantity) {
      cart.incrementQuantity(product.id);
    }
  }
  return !cart.isEmpty;
}

Future<bool> addProductToCart(BuildContext context, Product product) {
  return CartManager.instance.requestAddProduct(
    product,
    onStoreConflict: ({required previousStoreName, required newStoreName}) {
      return _showClearCartDialog(
        context,
        previousStoreName: previousStoreName,
        newStoreName: newStoreName,
      );
    },
  );
}

Future<bool> _showClearCartDialog(
  BuildContext context, {
  required String previousStoreName,
  required String newStoreName,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('تفريغ السلة؟'),
        content: Text(
          'سلتك تحتوي على أصناف من $previousStoreName. '
          'هل تريد إزالتها وإضافة أصناف من $newStoreName؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
            child: const Text('تفريغ وإضافة'),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
