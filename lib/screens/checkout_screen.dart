import 'package:delevery_app/data/cart_manager.dart';
import 'package:delevery_app/data/orders_manager.dart';
import 'package:delevery_app/services/storage_service.dart';
import 'package:delevery_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _buildingController = TextEditingController();
  final _notesController = TextEditingController();
  final _phoneController = TextEditingController();
  String _paymentMethod = 'cash';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCheckoutCache();
  }

  Future<void> _loadCheckoutCache() async {
    final cache = await StorageService.instance.loadCheckoutCache();
    if (!mounted || cache.isEmpty) {
      return;
    }
    setState(() {
      _streetController.text = cache.street;
      _buildingController.text = cache.building;
      _notesController.text = cache.notes;
      _phoneController.text = cache.phone;
    });
  }

  @override
  void dispose() {
    _streetController.dispose();
    _buildingController.dispose();
    _notesController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _buildDeliveryAddress() {
    final street = _streetController.text.trim();
    final building = _buildingController.text.trim();
    final notes = _notesController.text.trim();
    final base = '$street، $building';
    if (notes.isEmpty) {
      return base;
    }
    return '$base — $notes';
  }

  Future<void> _onConfirmPlaceOrder() async {
    if (_isSubmitting || CartManager.instance.isEmpty) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final address = _buildDeliveryAddress();
    final phone = _phoneController.text.trim();
    final checkoutCache = CheckoutFormCache(
      street: _streetController.text.trim(),
      building: _buildingController.text.trim(),
      notes: _notesController.text.trim(),
      phone: phone,
    );

    try {
      await OrdersManager.instance.placeOrder(
        deliveryAddress: address,
        phone: phone,
        checkoutCache: checkoutCache,
      );
      if (!mounted) {
        return;
      }
      CartManager.instance.clear();
      _showSuccessDialog();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'حدث خطأ أثناء إرسال الطلب، يرجى التحقق من الاتصال بالإنترنت.',
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'تم استلام طلبك بنجاح!',
                textAlign: TextAlign.center,
                style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'طلبك قيد التحضير الآن',
                textAlign: TextAlign.center,
                style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _returnToHome(dialogContext),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'العودة للرئيسية',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _returnToHome(BuildContext dialogContext) {
    Navigator.of(dialogContext).pop();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartManager.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('إتمام الطلب')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            _SectionTitle(title: 'عنوان التوصيل'),
            const SizedBox(height: 10),
            _CheckoutTextField(
              controller: _streetController,
              label: 'اسم الشارع والمنطقة',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال الشارع والمنطقة';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            _CheckoutTextField(
              controller: _buildingController,
              label: 'رقم العمارة / الدور / الشقة',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'يرجى إدخال بيانات العمارة';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            _CheckoutTextField(
              controller: _notesController,
              label: 'ملاحظات التوصيل (اختياري)',
              maxLines: 2,
            ),
            const SizedBox(height: 22),
            _SectionTitle(title: 'بيانات التواصل'),
            const SizedBox(height: 10),
            _CheckoutTextField(
              controller: _phoneController,
              label: 'رقم هاتف المستلم',
              keyboardType: TextInputType.phone,
              validator: (value) {
                final phone = value?.trim() ?? '';
                if (phone.isEmpty) {
                  return 'يرجى إدخال رقم الهاتف';
                }
                final egyptMobile = RegExp(r'^01[0125]\d{8}$');
                if (!egyptMobile.hasMatch(phone)) {
                  return 'رقم غير صالح (مثال: 01012345678)';
                }
                return null;
              },
            ),
            const SizedBox(height: 22),
            _SectionTitle(title: 'طريقة الدفع'),
            const SizedBox(height: 10),
            _PaymentMethodCard(
              selected: _paymentMethod == 'cash',
              onTap: () => setState(() => _paymentMethod = 'cash'),
            ),
            const SizedBox(height: 22),
            _SectionTitle(title: 'ملخص الطلب'),
            const SizedBox(height: 10),
            _CheckoutSummaryCard(
              subtotal: cart.subtotal,
              deliveryFee: CartManager.deliveryFee,
              total: cart.orderTotal,
            ),
            const SizedBox(height: 20),
            FilledButton(
              key: const Key('confirm_place_order'),
              onPressed: _isSubmitting ? null : _onConfirmPlaceOrder,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'تأكيد وإرسال الطلب',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
    );
  }
}

class _CheckoutTextField extends StatelessWidget {
  const _CheckoutTextField({
    required this.controller,
    required this.label,
    this.validator,
    this.maxLines = 1,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.radio_button_checked, color: AppColors.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'الدفع نقداً عند الاستلام',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckoutSummaryCard extends StatelessWidget {
  const _CheckoutSummaryCard({
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  final double subtotal;
  final double deliveryFee;
  final double total;

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
