import 'package:delevery_app/data/cart_manager.dart';
import 'package:delevery_app/screens/cart_screen.dart';
import 'package:delevery_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum StickyCartBarVariant { standard, storeBasket }

class StickyCartBar extends StatelessWidget {
  const StickyCartBar({
    super.key,
    this.variant = StickyCartBarVariant.standard,
    this.showFreeDeliveryHint = false,
  });

  final StickyCartBarVariant variant;
  final bool showFreeDeliveryHint;

  @override
  Widget build(BuildContext context) {
    final cart = CartManager.instance;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListenableBuilder(
          listenable: cart,
          builder: (context, _) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              layoutBuilder: (currentChild, previousChildren) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ...previousChildren,
                    ?currentChild,
                  ],
                );
              },
              transitionBuilder: (child, animation) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.35),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: cart.isEmpty
                  ? const SizedBox.shrink(key: ValueKey('sticky_cart_empty'))
                  : variant == StickyCartBarVariant.storeBasket
                      ? _StoreBasketBarBody(
                          key: const ValueKey('store_basket_visible'),
                          itemCount: cart.totalQuantity,
                          subtotal: cart.subtotal,
                          showFreeDeliveryHint: showFreeDeliveryHint,
                          onTap: () => _openCart(context),
                        )
                      : _StickyCartBarBody(
                          key: const ValueKey('sticky_cart_visible'),
                          itemCount: cart.totalQuantity,
                          subtotal: cart.subtotal,
                          onTap: () => _openCart(context),
                        ),
            );
          },
        ),
      ],
    );
  }

  void _openCart(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CartScreen(),
      ),
    );
  }
}

class _StickyCartBarBody extends StatelessWidget {
  const _StickyCartBarBody({
    super.key,
    required this.itemCount,
    required this.subtotal,
    required this.onTap,
  });

  final int itemCount;
  final double subtotal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Material(
        color: AppColors.primary,
        elevation: 6,
        shadowColor: AppColors.primary.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$itemCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'عرض السلة',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                Text(
                  '${_formatPrice(subtotal)} ج.م',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_left,
                  size: 18,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StoreBasketBarBody extends StatelessWidget {
  const _StoreBasketBarBody({
    super.key,
    required this.itemCount,
    required this.subtotal,
    required this.showFreeDeliveryHint,
    required this.onTap,
  });

  final int itemCount;
  final double subtotal;
  final bool showFreeDeliveryHint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Material(
        color: AppColors.primary,
        elevation: 8,
        shadowColor: AppColors.primary.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$itemCount',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'عرض السلة (${_formatPrice(subtotal)} ج.م)',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (showFreeDeliveryHint) ...[
                        const SizedBox(height: 4),
                        const Text(
                          'رائع! حصلت على توصيل مجاني لهذا الطلب!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 11.5,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatPrice(double price) {
  if (price == price.roundToDouble()) {
    return price.toStringAsFixed(0);
  }
  return price.toStringAsFixed(2);
}
