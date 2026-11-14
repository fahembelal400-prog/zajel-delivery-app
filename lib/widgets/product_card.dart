import 'package:delevery_app/data/cart_actions.dart';
import 'package:delevery_app/data/cart_manager.dart';
import 'package:delevery_app/models/product.dart';
import 'package:delevery_app/theme/app_colors.dart';
import 'package:delevery_app/widgets/product_details_sheet.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final Product product;

  void _openDetails(BuildContext context) {
    showProductDetailsSheet(context, product);
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartManager.instance;

    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        final quantity = cart.quantityFor(product.id);

        return Material(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: () => _openDetails(context),
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _ProductImageArea(
                      product: product,
                      quantity: quantity,
                      onOpenDetails: () => _openDetails(context),
                      onAdd: () => addProductToCart(context, product),
                      onIncrement: () => addProductToCart(context, product),
                      onDecrement: () => cart.decrementQuantity(product.id),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    height: 1.2,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.unitLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        _PriceRow(product: product),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        Text(
          '${_formatPrice(product.price)} ج.م',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
        ),
        if (product.hasDiscount)
          Text(
            '${_formatPrice(product.originalPrice!)} ج.م',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textHint,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: AppColors.textHint,
                ),
          ),
      ],
    );
  }
}

class _ProductImageArea extends StatelessWidget {
  const _ProductImageArea({
    required this.product,
    required this.quantity,
    required this.onOpenDetails,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  final Product product;
  final int quantity;
  final VoidCallback onOpenDetails;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Material(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onOpenDetails,
                borderRadius: BorderRadius.circular(12),
                child: _ProductThumbnail(imageUrl: product.imageUrl),
              ),
            ),
          ),
          Positioned(
            right: 4,
            bottom: 4,
            child: _QuickQuantityControl(
              quantity: quantity,
              onAdd: onAdd,
              onIncrement: onIncrement,
              onDecrement: onDecrement,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickQuantityControl extends StatelessWidget {
  const _QuickQuantityControl({
    required this.quantity,
    required this.onAdd,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: quantity == 0
          ? Material(
              key: const ValueKey('add'),
              color: AppColors.primary,
              shape: const CircleBorder(),
              elevation: 2,
              shadowColor: AppColors.primary.withValues(alpha: 0.35),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onAdd,
                child: const SizedBox(
                  width: 34,
                  height: 34,
                  child: Icon(Icons.add, color: Colors.white, size: 22),
                ),
              ),
            )
          : Material(
              key: const ValueKey('stepper'),
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
              elevation: 2,
              shadowColor: AppColors.primary.withValues(alpha: 0.35),
              child: SizedBox(
                height: 34,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StepperIconButton(
                      icon: Icons.remove,
                      onTap: onDecrement,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '$quantity',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    _StepperIconButton(
                      icon: Icons.add,
                      onTap: onIncrement,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _StepperIconButton extends StatelessWidget {
  const _StepperIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return const Center(
        child: Icon(
          Icons.shopping_bag_outlined,
          color: AppColors.primary,
          size: 40,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const Center(
          child: Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
        ),
      ),
    );
  }
}

String _formatPrice(double price) {
  return price.toStringAsFixed(2);
}
