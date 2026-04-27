import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/cart.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets.dart' as shared;

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _address1Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  String _selectedDeliveryZone = 'Nairobi CBD';
  ShippingOption? _selectedShipping;
  List<ShippingOption> _shippingOptions = [];
  bool _loadingShipping = false;
  bool _submitting = false;

  static const _deliveryZones = [
    'Nairobi CBD',
    'Westlands',
    'Karen',
    'Kilimani',
    'Lavington',
    'Parklands',
    'Gigiri',
    'Runda',
    'Muthaiga',
    'Eastleigh',
    'Kasarani',
    'Ruiru',
    'Thika',
    'Kiambu',
  ];

  @override
  void initState() {
    super.initState();
    _prefillFromAuth();
    _loadShipping();
  }

  void _prefillFromAuth() {
    final customer = ref.read(authProvider).customer;
    if (customer != null) {
      _firstNameCtrl.text = customer.firstName;
      _lastNameCtrl.text = customer.lastName;
      _emailCtrl.text = customer.email;
      _phoneCtrl.text = customer.phone ?? '';
    }
  }

  Future<void> _loadShipping() async {
    setState(() => _loadingShipping = true);
    try {
      final options =
          await ref.read(cartProvider.notifier).getShippingOptions();
      setState(() {
        _shippingOptions = options;
        if (options.isNotEmpty) _selectedShipping = options.first;
      });
    } catch (_) {
      // Shipping options unavailable — proceed anyway
    } finally {
      if (mounted) setState(() => _loadingShipping = false);
    }
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      // Update cart with address & email
      await ref.read(cartProvider.notifier).setEmail(_emailCtrl.text.trim());
      await ref.read(cartProvider.notifier).setShippingAddress(
            ShippingAddress(
              firstName: _firstNameCtrl.text.trim(),
              lastName: _lastNameCtrl.text.trim(),
              address1: _address1Ctrl.text.trim(),
              city: _cityCtrl.text.trim().isNotEmpty
                  ? _cityCtrl.text.trim()
                  : _selectedDeliveryZone,
              phone: _phoneCtrl.text.trim(),
              countryCode: 'ke',
            ),
          );

      if (_selectedShipping != null) {
        await ref
            .read(cartProvider.notifier)
            .selectShippingMethod(_selectedShipping!.id);
      }

      final cart = ref.read(cartProvider).valueOrNull;
      if (cart == null) return;

      // Navigate to M-Pesa payment
      context.push('/checkout/payment', extra: {'cartId': cart.id});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Something went wrong. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _address1Ctrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _Section(title: 'Contact Information', children: [
                Row(children: [
                  Expanded(
                    child: _Field(
                      label: 'First name',
                      controller: _firstNameCtrl,
                      validator: _required,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Field(
                      label: 'Last name',
                      controller: _lastNameCtrl,
                      validator: _required,
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                _Field(
                  label: 'Email address',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _Field(
                  label: 'Phone (M-Pesa number)',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  hint: '+254 7XX XXX XXX',
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final digits = v.replaceAll(RegExp(r'\D'), '');
                    if (digits.length < 9) return 'Enter a valid Kenyan number';
                    return null;
                  },
                ),
              ]),
              const SizedBox(height: 16),
              _Section(title: 'Delivery Address', children: [
                _Field(
                  label: 'Street address',
                  controller: _address1Ctrl,
                  hint: 'e.g. 14 Ngong Road, Apt 3',
                  validator: _required,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedDeliveryZone,
                  decoration: const InputDecoration(labelText: 'Delivery Zone'),
                  items: _deliveryZones
                      .map((z) =>
                          DropdownMenuItem(value: z, child: Text(z)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _selectedDeliveryZone = v!),
                ),
              ]),
              const SizedBox(height: 16),
              _Section(title: 'Delivery Method', children: [
                if (_loadingShipping)
                  const Center(
                      child: CircularProgressIndicator(strokeWidth: 2))
                else if (_shippingOptions.isEmpty)
                  const Text(
                    'Standard delivery will be applied.',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontFamily: 'Poppins'),
                  )
                else
                  ..._shippingOptions.map((opt) => RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: Text(opt.name,
                            style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 14)),
                        subtitle: Text(opt.formattedAmount,
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                        value: opt.id,
                        groupValue: _selectedShipping?.id,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(
                            () => _selectedShipping = opt),
                      )),
              ]),
              if (cart != null) ...[
                const SizedBox(height: 16),
                _Section(title: 'Order Total', children: [
                  _SummaryRow('Subtotal', cart.formattedSubtotal),
                  const SizedBox(height: 6),
                  _SummaryRow(
                      'Delivery',
                      _selectedShipping?.formattedAmount ??
                          cart.formattedShipping),
                  const Divider(height: 20),
                  _SummaryRow('Total', cart.formattedTotal, bold: true),
                ]),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: ElevatedButton.icon(
            onPressed: _submitting ? null : _placeOrder,
            icon: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.phone_android_rounded),
            label: Text(_submitting ? 'Please wait…' : 'Pay with M-Pesa'),
          ),
        ),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.isEmpty) ? 'Required' : null;
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _SummaryRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: bold ? 15 : 14,
                fontWeight:
                    bold ? FontWeight.w600 : FontWeight.w400,
                color: bold
                    ? AppColors.textPrimary
                    : AppColors.textSecondary)),
        Text(value,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: bold ? 16 : 14,
                fontWeight:
                    bold ? FontWeight.w700 : FontWeight.w500,
                color: bold
                    ? AppColors.primary
                    : AppColors.textPrimary)),
      ],
    );
  }
}
