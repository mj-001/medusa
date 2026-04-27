import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: auth.isLoggedIn
          ? _LoggedInView(auth: auth)
          : _GuestView(),
    );
  }
}

class _GuestView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.divider,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 40, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          const Text(
            'Not signed in',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Sign in to access your orders and profile.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.textSecondary, fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () => context.push('/auth/login'),
            child: const Text('Sign In'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.push('/auth/register'),
            child: const Text('Create Account'),
          ),
          const SizedBox(height: 32),
          _AppInfoSection(),
        ],
      ),
    );
  }
}

class _LoggedInView extends ConsumerWidget {
  final AuthState auth;
  const _LoggedInView({required this.auth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = auth.customer!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                customer.firstName.isNotEmpty
                    ? customer.firstName[0].toUpperCase()
                    : customer.email[0].toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            customer.fullName.isNotEmpty ? customer.fullName : 'Customer',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            customer.email,
            style: const TextStyle(
                color: AppColors.textSecondary, fontFamily: 'Poppins'),
          ),
          if (customer.phone != null) ...[
            const SizedBox(height: 4),
            Text(
              customer.phone!,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Poppins',
                  fontSize: 13),
            ),
          ],
          const SizedBox(height: 24),
          _MenuSection(items: [
            _MenuItem(
              icon: Icons.receipt_long_outlined,
              label: 'My Orders',
              onTap: () => context.go('/orders'),
            ),
            _MenuItem(
              icon: Icons.location_on_outlined,
              label: 'Delivery Addresses',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 16),
          _MenuSection(items: [
            _MenuItem(
              icon: Icons.info_outline,
              label: 'About FreshKe',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.headset_mic_outlined,
              label: 'Contact Support',
              subtitle: 'support@freshke.co.ke',
              onTap: () {},
            ),
            _MenuItem(
              icon: Icons.policy_outlined,
              label: 'Privacy Policy',
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 16),
          _MenuSection(items: [
            _MenuItem(
              icon: Icons.logout_rounded,
              label: 'Sign Out',
              labelColor: AppColors.error,
              iconColor: AppColors.error,
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Sign out?'),
                    content: const Text(
                        'You\'ll need to sign in again to view your orders.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Sign Out',
                              style: TextStyle(color: AppColors.error))),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref.read(authProvider.notifier).logout();
                }
              },
            ),
          ]),
          const SizedBox(height: 16),
          _AppInfoSection(),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon,
                    color: item.iconColor ?? AppColors.textSecondary),
                title: Text(
                  item.label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: item.labelColor ?? AppColors.textPrimary,
                  ),
                ),
                subtitle: item.subtitle != null
                    ? Text(item.subtitle!,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontFamily: 'Poppins'))
                    : null,
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textSecondary, size: 20),
                onTap: item.onTap,
              ),
              if (i < items.length - 1)
                const Divider(height: 1, indent: 54),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? labelColor;
  final Color? iconColor;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.labelColor,
    this.iconColor,
    required this.onTap,
  });
}

class _AppInfoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (ctx, snap) => Text(
        snap.hasData
            ? 'FreshKe v${snap.data!.version} · Powered by Medusa'
            : 'FreshKe · Powered by Medusa',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontFamily: 'Poppins',
          fontSize: 12,
        ),
      ),
    );
  }
}
