import 'package:delevery_app/data/cart_manager.dart';
import 'package:delevery_app/models/cart_item.dart';
import 'package:delevery_app/screens/checkout_screen.dart';
import 'package:delevery_app/theme/app_colors.dart';
import 'package:delevery_app/widgets/app_shell_scope.dart';
import 'package:delevery_app/widgets/empty_state_widget.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartManager.instance;

    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('السلة'),
          ),
          body: cart.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.shopping_bag_outlined,
                  title: 'سلتك فارغة حالياً',
                  subtitle:
                      'تصفح المتاجر القريبة وأضف احتياجاتك اليومية للبدء.',
                  buttonLabel: 'ابدأ التسوق',
                  onButtonPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    AppShellScope.maybeOf(context)?.goToHome();
                  },
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: cart.items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          return CartItemTile(item: cart.items[index]);
                        },
                      ),
                    ),
                    _OrderSummary(
                      subtotal: cart.subtotal,
                      deliveryFee: CartManager.deliveryFee,
                      total: cart.orderTotal,
                      onProceedToCheckout: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const CheckoutScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class CartItemTile extends StatelessWidget {
  const CartItemTile({super.key, required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cart = CartManager.instance;
    final product = item.product;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_formatPrice(item.lineTotal)} ج.م',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _QuantityButton(
                icon: Icons.remove,
                onTap: () => cart.decrementQuantity(product.id),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${item.quantity}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              _QuantityButton(
                icon: Icons.add,
                filled: true,
                onTap: () => cart.incrementQuantity(product.id),
              ),
              IconButton(
                onPressed: () => cart.removeItem(product.id),
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            size: 18,
            color: filled ? AppColors.onPrimary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.onProceedToCheckout,
  });

  final double subtotal;
  final double deliveryFee;
  final double total;
  final VoidCallback onProceedToCheckout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryRow(
            label: 'المجموع',
            value: '${_formatPrice(subtotal)} ج.م',
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'مصاريف التوصيل',
            value: '${_formatPrice(deliveryFee)} ج.م',
          ),
          const Divider(height: 24),
          _SummaryRow(
            label: 'الإجمالي',
            value: '${_formatPrice(total)} ج.م',
            emphasized: true,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onProceedToCheckout,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'متابعة لإتمام الطلب',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final style = emphasized
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            )
        : Theme.of(context).textTheme.bodyLarge;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}

String _formatPrice(double price) {
  if (price == price.roundToDouble()) {
    return price.toStringAsFixed(0);
  }
  return price.toStringAsFixed(1);
}
