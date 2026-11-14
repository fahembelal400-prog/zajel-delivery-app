import 'package:delevery_app/data/cart_actions.dart';
import 'package:delevery_app/data/cart_manager.dart';
import 'package:delevery_app/models/product.dart';
import 'package:delevery_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

Future<void> showProductDetailsSheet(BuildContext context, Product product) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ProductDetailsSheet(product: product),
  );
}

class ProductDetailsSheet extends StatelessWidget {
  const ProductDetailsSheet({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final cart = CartManager.instance;
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        final quantity = cart.quantityFor(product.id);

        return Padding(
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.88,
            ),
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SheetProductImage(imageUrl: product.imageUrl),
                    const SizedBox(height: 16),
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.unitLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        '${_formatPrice(product.price)} ج.م',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _QuantityStepper(
                      quantity: quantity,
                      onDecrement: () => cart.decrementQuantity(product.id),
                      onIncrement: () async {
                        if (quantity == 0) {
                          await addProductToCart(context, product);
                        } else {
                          cart.incrementQuantity(product.id);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () async {
                        if (quantity == 0) {
                          final added = await addProductToCart(context, product);
                          if (!added || !context.mounted) {
                            return;
                          }
                        }
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        quantity == 0 ? 'أضف إلى السلة' : 'تحديث السلة',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final Future<void> Function() onIncrement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StepperButton(
          icon: Icons.remove,
          enabled: quantity > 0,
          onTap: onDecrement,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            '$quantity',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        _StepperButton(
          icon: Icons.add,
          enabled: true,
          onTap: () => onIncrement(),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? AppColors.surface : AppColors.surface.withValues(alpha: 0.5),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            icon,
            color: enabled ? AppColors.textPrimary : AppColors.textHint,
          ),
        ),
      ),
    );
  }
}

class _SheetProductImage extends StatelessWidget {
  const _SheetProductImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: imageUrl.isEmpty
          ? const Center(
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 72,
                color: AppColors.primary,
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Center(
                  child: Icon(Icons.shopping_bag_outlined, size: 72),
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
  return price.toStringAsFixed(1);
}
