import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/cart_provider.dart';
import '../../core/theme/app_theme.dart';

class MpesaPaymentScreen extends ConsumerStatefulWidget {
  final String cartId;
  const MpesaPaymentScreen({super.key, required this.cartId});

  @override
  ConsumerState<MpesaPaymentScreen> createState() =>
      _MpesaPaymentScreenState();
}

class _MpesaPaymentScreenState extends ConsumerState<MpesaPaymentScreen>
    with SingleTickerProviderStateMixin {
  final _phoneCtrl = TextEditingController();
  bool _sending = false;
  bool _waitingConfirmation = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.9, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendStk() async {
    if (_phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your M-Pesa phone number')),
      );
      return;
    }
    setState(() {
      _sending = true;
      _waitingConfirmation = false;
    });

    // Simulate STK push — in production this triggers via Medusa payment
    // provider plugin (e.g. medusa-payment-mpesa or Daraja API integration).
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() {
      _sending = false;
      _waitingConfirmation = true;
    });
  }

  Future<void> _confirmPaid() async {
    setState(() => _sending = true);
    try {
      final result = await ref.read(cartProvider.notifier).completeOrder();
      if (!mounted) return;
      final orderId = result?['data']?['id'] as String? ?? '';
      context.go('/checkout/success', extra: {'orderId': orderId});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Payment not confirmed yet. Please approve the M-Pesa prompt.'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('M-Pesa Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // M-Pesa logo placeholder
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF006600),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(
                child: Text(
                  'M-PESA',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (cart != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Amount to pay: ',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      cart.formattedTotal,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            if (!_waitingConfirmation) ...[
              const Text(
                'Enter your M-Pesa number to receive a payment prompt:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'M-Pesa Phone Number',
                  hintText: '+254 7XX XXX XXX',
                  prefixIcon: Icon(Icons.phone_android_rounded),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _sending ? null : _sendStk,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006600),
                ),
                icon: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send_rounded),
                label:
                    Text(_sending ? 'Sending prompt…' : 'Send M-Pesa Prompt'),
              ),
            ] else ...[
              // Waiting for user to approve STK push
              ScaleTransition(
                scale: _pulse,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF006600).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phone_android_rounded,
                      size: 40, color: Color(0xFF006600)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'M-Pesa prompt sent!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Check your phone (${_phoneCtrl.text.trim()}) and enter your M-Pesa PIN to complete payment.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _sending ? null : _confirmPaid,
                child: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('I have paid — Confirm Order'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () =>
                    setState(() => _waitingConfirmation = false),
                child: const Text('Resend prompt'),
              ),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_rounded,
                      size: 18, color: AppColors.primary),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your payment is secured by Safaricom M-Pesa. We never store your PIN.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
