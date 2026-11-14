import 'package:delevery_app/services/storage_service.dart';
import 'package:delevery_app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ProfileEditSheet extends StatefulWidget {
  const ProfileEditSheet({super.key, required this.initial});

  final CheckoutFormCache initial;

  static Future<CheckoutFormCache?> show(
    BuildContext context, {
    required CheckoutFormCache initial,
  }) {
    return showModalBottomSheet<CheckoutFormCache>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProfileEditSheet(initial: initial),
    );
  }

  @override
  State<ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends State<ProfileEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _streetController;
  late final TextEditingController _buildingController;
  late final TextEditingController _notesController;
  bool _saving = false;

  static final _egyptMobile = RegExp(r'^01[0125]\d{8}$');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initial.customerName);
    _phoneController = TextEditingController(text: widget.initial.phone);
    _streetController = TextEditingController(text: widget.initial.street);
    _buildingController = TextEditingController(text: widget.initial.building);
    _notesController = TextEditingController(text: widget.initial.notes);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _saving = true);
    final updated = CheckoutFormCache(
      customerName: _nameController.text.trim(),
      street: _streetController.text.trim(),
      building: _buildingController.text.trim(),
      notes: _notesController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    await StorageService.instance.saveCheckoutCache(updated);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.viewInsetsOf(context);

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'تعديل البيانات المحفوظة',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ProfileField(
                          controller: _nameController,
                          label: 'الاسم الكامل',
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        _ProfileField(
                          controller: _phoneController,
                          label: 'رقم الهاتف',
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            final phone = value?.trim() ?? '';
                            if (phone.isEmpty) {
                              return null;
                            }
                            if (!_egyptMobile.hasMatch(phone)) {
                              return 'رقم غير صالح (مثال: 01012345678)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'عنوان التوصيل',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                        ),
                        const SizedBox(height: 10),
                        _ProfileField(
                          controller: _streetController,
                          label: 'الشارع والمنطقة',
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        _ProfileField(
                          controller: _buildingController,
                          label: 'العمارة / الدور / الشقة',
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        _ProfileField(
                          controller: _notesController,
                          label: 'ملاحظات التوصيل (اختياري)',
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _saving ? null : _save,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.onPrimary,
                                  ),
                                )
                              : const Text(
                                  'حفظ البيانات',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    required this.label,
    this.validator,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.profileBackground,
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
