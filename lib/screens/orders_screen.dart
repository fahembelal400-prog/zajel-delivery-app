import 'package:delevery_app/data/orders_manager.dart';
import 'package:delevery_app/models/order_model.dart';
import 'package:delevery_app/screens/order_details_screen.dart';
import 'package:delevery_app/theme/app_colors.dart';
import 'package:delevery_app/widgets/app_shell_scope.dart';
import 'package:delevery_app/widgets/empty_state_widget.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ordersManager = OrdersManager.instance;

    return ListenableBuilder(
      listenable: ordersManager,
      builder: (context, _) {
        if (ordersManager.isEmpty) {
          return ColoredBox(
            color: AppColors.background,
            child: SafeArea(
              child: Center(
                child: EmptyStateWidget(
                  icon: Icons.receipt_long_outlined,
                  title: 'لا توجد طلبات بعد',
                  subtitle:
                      'بمجرد إتمام طلبك، يمكنك متابعة حالته مباشرة من هنا.',
                  buttonLabel: 'تصفح المتاجر',
                  onButtonPressed: () {
                    AppShellScope.of(context).goToHome();
                  },
                ),
              ),
            ),
          );
        }

        return ColoredBox(
          color: AppColors.background,
          child: SafeArea(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: ordersManager.orders.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return OrderCard(order: ordersManager.orders[index]);
              },
            ),
          ),
        );
      },
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => OrderDetailsScreen(orderId: order.orderId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.storeName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
              _StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatDateTime(order.dateTime),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoChip(
                icon: Icons.shopping_bag_outlined,
                label: '${order.itemsCount} صنف',
              ),
              const SizedBox(width: 12),
              _InfoChip(
                icon: Icons.payments_outlined,
                label: '${_formatPrice(order.totalAmount)} ج.م',
              ),
            ],
          ),
        ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

String _formatDateTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '${dateTime.day}/${dateTime.month}/${dateTime.year} · $hour:$minute';
}

String _formatPrice(double price) {
  if (price == price.roundToDouble()) {
    return price.toStringAsFixed(0);
  }
  return price.toStringAsFixed(1);
}
