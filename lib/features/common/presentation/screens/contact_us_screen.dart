import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  static const String _phone = '+91 7056222557';
  static const String _email = 'hello@scanaura.in';
  static const String _whatsAppPhone = '917056222557';

  Future<void> _openUrl(
      BuildContext context,
      Uri uri,
      ) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Unable to open the requested link.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Unable to open the requested link.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    }
  }

  Future<void> _call(BuildContext context) {
    return _openUrl(
      context,
      Uri.parse('tel:+917056222557'),
    );
  }

  Future<void> _emailUs(BuildContext context) {
    return _openUrl(
      context,
      Uri(
        scheme: 'mailto',
        path: _email,
        queryParameters: const {
          'subject': 'ScanAura Support Request',
        },
      ),
    );
  }

  Future<void> _whatsApp(BuildContext context) {
    const message =
        'Hi ScanAura Support, I need help with my business account.';

    return _openUrl(
      context,
      Uri.parse(
        'https://wa.me/$_whatsAppPhone?text=${Uri.encodeComponent(message)}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          'Contact Us',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'We are here to help with your ScanAura business account.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  _sectionCard(
                    context,
                    title: 'ScanAura Support',
                    icon: Icons.support_agent_rounded,
                    children: [
                      _contactTile(
                        context,
                        icon: Icons.phone_outlined,
                        title: 'Call Us',
                        subtitle: _phone,
                        onTap: () => _call(context),
                      ),
                      const SizedBox(height: 10),
                      _contactTile(
                        context,
                        icon: Icons.chat_rounded,
                        title: 'WhatsApp',
                        subtitle: 'Chat with ScanAura Support',
                        onTap: () => _whatsApp(context),
                      ),
                      const SizedBox(height: 10),
                      _contactTile(
                        context,
                        icon: Icons.email_outlined,
                        title: 'Email Us',
                        subtitle: _email,
                        onTap: () => _emailUs(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  _sectionCard(
                    context,
                    title: 'About ScanAura',
                    icon: Icons.qr_code_2_rounded,
                    children: [
                      Text(
                        'ScanAura provides digital business tools such as QR menus, catalog management and customer-facing business pages for local businesses.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Operated by Balaji Tech Solutions',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  _sectionCard(
                    context,
                    title: 'Terms of Use',
                    icon: Icons.description_outlined,
                    children: [
                      const Text(
                        'ScanAura is provided to help businesses manage digital information and services. Business owners are responsible for the accuracy and legality of the information they publish. Features and services may be updated as the platform evolves.',
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _sectionCard(
                    context,
                    title: 'Privacy',
                    icon: Icons.privacy_tip_outlined,
                    children: [
                      const Text(
                        'We use information provided by business owners to operate, maintain and support ScanAura services. We aim to protect account and business information and use it only for legitimate platform and support purposes.',
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _sectionCard(
                    context,
                    title: 'Refund Policy',
                    icon: Icons.currency_rupee_rounded,
                    children: [
                      const Text(
                        'Refund eligibility depends on the service, subscription and payment terms applicable at the time of purchase. Contact ScanAura Support with your payment or subscription details for assistance.',
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: Text(
                      'Need help? Contact ScanAura Support.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required List<Widget> children,
      }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _contactTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
