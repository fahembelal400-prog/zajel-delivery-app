import 'package:delevery_app/data/orders_manager.dart';
import 'package:delevery_app/models/order_model.dart';
import 'package:delevery_app/models/order_tracking.dart';
import 'package:delevery_app/theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final ordersManager = OrdersManager.instance;

    return ListenableBuilder(
      listenable: ordersManager,
      builder: (context, _) {
        final order = ordersManager.findById(orderId);
        if (order == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('تفاصيل الطلب')),
            body: const Center(child: Text('الطلب غير موجود')),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('تفاصيل الطلب'),
            actions: [
              if (kDebugMode)
                IconButton(
                  tooltip: 'Simulate Status Next Step',
                  onPressed: () async {
                    await ordersManager.advanceTrackingStep(orderId);
                  },
                  icon: const Icon(Icons.skip_next_outlined),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _OrderMetaCard(order: order),
              const SizedBox(height: 16),
              _OrderTrackingStepper(trackingStep: order.trackingStep),
              const SizedBox(height: 16),
              _DeliveryInfoCard(order: order),
              const SizedBox(height: 16),
              _ItemsReceiptCard(order: order),
              const SizedBox(height: 16),
              _BillBreakdownCard(order: order),
              const SizedBox(height: 16),
              _OrderHelpCard(orderId: order.orderId),
              if (kDebugMode) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    await ordersManager.advanceTrackingStep(orderId);
                  },
                  icon: const Icon(Icons.fast_forward_outlined),
                  label: const Text('Simulate Status Next Step'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _OrderMetaCard extends StatelessWidget {
  const _OrderMetaCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'طلب #${order.orderId}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              _StatusPill(status: order.status, trackingStep: order.trackingStep),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatDateTime(order.dateTime),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            order.storeName,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _OrderTrackingStepper extends StatelessWidget {
  const _OrderTrackingStepper({required this.trackingStep});

  static const _inactiveGrey = Color(0xFFE0E0E0);

  final String trackingStep;

  @override
  Widget build(BuildContext context) {
    final activeIndex = trackingStepIndex(trackingStep);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < orderTrackingSteps.length; i++) ...[
              _StepNode(
                label: orderTrackingStepLabelsAr[orderTrackingSteps[i]]!,
                index: i,
                activeIndex: activeIndex,
              ),
              if (i < orderTrackingSteps.length - 1)
                _StepConnector(
                  isCompleted: i < activeIndex,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({
    required this.label,
    required this.index,
    required this.activeIndex,
  });

  final String label;
  final int index;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final isCompleted = index < activeIndex;
    final isActive = index == activeIndex;
    final isInactive = index > activeIndex;

    final Color circleColor;
    final Color iconColor;
    final IconData icon;

    if (isCompleted) {
      circleColor = AppColors.primary;
      iconColor = AppColors.onPrimary;
      icon = Icons.check_rounded;
    } else if (isActive) {
      circleColor = AppColors.primary;
      iconColor = AppColors.onPrimary;
      icon = Icons.schedule_rounded;
    } else {
      circleColor = _OrderTrackingStepper._inactiveGrey;
      iconColor = AppColors.textHint;
      icon = Icons.circle_outlined;
    }

    final textColor = isInactive
        ? AppColors.textSecondary
        : AppColors.textPrimary;

    return SizedBox(
      width: 88,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: textColor,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  height: 1.15,
                ),
          ),
        ],
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  const _StepConnector({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 28,
      height: 3,
      margin: const EdgeInsets.only(bottom: 28),
      decoration: BoxDecoration(
        color: isCompleted ? AppColors.primary : const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _OrderHelpCard extends StatelessWidget {
  const _OrderHelpCard({required this.orderId});

  final String orderId;

  void _openHelpSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                Text(
                  'تحتاج مساعدة في هذا الطلب؟',
                  style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.support_agent, color: AppColors.primary),
                  title: const Text('التواصل مع خدمة العملاء'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: AppColors.surface,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('خدمة العملاء (قريباً)'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.report_outlined, color: AppColors.error),
                  title: const Text('الإبلاغ عن مشكلة'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: AppColors.surface,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('الإبلاغ عن مشكلة — الطلب #$orderId'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => _openHelpSheet(context),
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.help_outline, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تحتاج مساعدة في هذا الطلب؟',
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_left, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeliveryInfoCard extends StatelessWidget {
  const _DeliveryInfoCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'التوصيل والتواصل',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(order.deliveryAddress)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.phone_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(order.phone),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemsReceiptCard extends StatelessWidget {
  const _ItemsReceiptCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'الأصناف',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 12),
          for (final item in order.items) ...[
            _ReceiptLine(item: item),
            if (item != order.items.last) const Divider(height: 20),
          ],
        ],
      ),
    );
  }
}

class _ReceiptLine extends StatelessWidget {
  const _ReceiptLine({required this.item});

  final OrderLineItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatPrice(item.unitPrice)} ج.م × ${item.quantity}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
        Text(
          '${_formatPrice(item.lineTotal)} ج.م',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
        ),
      ],
    );
  }
}

class _BillBreakdownCard extends StatelessWidget {
  const _BillBreakdownCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _BillRow(
            label: 'المجموع',
            value: '${_formatPrice(order.subtotal)} ج.م',
          ),
          const SizedBox(height: 8),
          _BillRow(
            label: 'مصاريف التوصيل',
            value: '${_formatPrice(order.deliveryFee)} ج.م',
          ),
          const Divider(height: 24),
          _BillRow(
            label: 'الإجمالي',
            value: '${_formatPrice(order.totalAmount)} ج.م',
            emphasized: true,
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.trackingStep});

  final String status;
  final String trackingStep;

  @override
  Widget build(BuildContext context) {
    final isDelivered = trackingStep == 'delivered';
    final isActive = trackingStep != 'placed';

  final Color bg;
    final Color fg;
    if (isDelivered) {
      bg = AppColors.success.withValues(alpha: 0.12);
      fg = AppColors.success;
    } else if (isActive) {
      bg = AppColors.primary.withValues(alpha: 0.12);
      fg = AppColors.primary;
    } else {
      bg = const Color(0xFFE0E0E0).withValues(alpha: 0.35);
      fg = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  const _BillRow({
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
