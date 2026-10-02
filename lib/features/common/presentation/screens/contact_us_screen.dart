import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  static const String _phone = '+91 7056222557';
  static const String _email = 'scanauraofficial@gmail.com';
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
        'https://wa.me/$_whatsAppPhone'
            '?text=${Uri.encodeComponent(message)}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ScanAura Support',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            40,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 820,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------------------------------------------------------
                  // HEADER
                  // ---------------------------------------------------------
                  Text(
                    'We are here to help with your ScanAura account.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ---------------------------------------------------------
                  // SUPPORT
                  // ---------------------------------------------------------
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

                  // ---------------------------------------------------------
                  // ABOUT
                  // ---------------------------------------------------------
                  _sectionCard(
                    context,
                    title: 'About ScanAura',
                    icon: Icons.qr_code_2_rounded,
                    children: [
                      Text(
                        'ScanAura is a digital platform that helps local '
                            'businesses create and manage a digital business '
                            'presence through QR codes, business pages, '
                            'digital menus, catalogues and related customer '
                            'engagement tools.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'ScanAura',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gurugram, Haryana, India',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ---------------------------------------------------------
                  // TERMS & CONDITIONS
                  // ---------------------------------------------------------
                  _legalCard(
                    context,
                    title: 'Terms & Conditions',
                    icon: Icons.description_outlined,
                    sections: const [
                      _LegalSection(
                        title: '1. About ScanAura',
                        body:
                        'ScanAura provides digital business tools and '
                            'digital business pages that allow businesses '
                            'to publish and manage information for their '
                            'customers. ScanAura is a technology and digital '
                            'platform provider and is not the seller or '
                            'service provider of products or services '
                            'displayed by individual businesses.',
                      ),
                      _LegalSection(
                        title: '2. Business Owner Responsibility',
                        body:
                        'Business owners are responsible for the '
                            'accuracy, legality and completeness of the '
                            'information they publish through ScanAura. '
                            'This includes business details, prices, '
                            'products, services, offers, availability, '
                            'images, contact information and external '
                            'links.',
                      ),
                      _LegalSection(
                        title: '3. Orders and Customer Transactions',
                        body:
                        'When a customer contacts a business through '
                            'WhatsApp, phone, social media, a website, '
                            'Google Maps or another external service linked '
                            'from a ScanAura page, the transaction or '
                            'communication is directly between the customer '
                            'and the business. ScanAura does not become a '
                            'party to that transaction.',
                      ),
                      _LegalSection(
                        title: '4. Products, Services and Fulfilment',
                        body:
                        'The business is responsible for the products '
                            'and services it provides, including pricing, '
                            'quality, availability, delivery, fulfilment, '
                            'refunds, cancellations and customer disputes. '
                            'ScanAura does not control these business '
                            'operations.',
                      ),
                      _LegalSection(
                        title: '5. QR Codes and Public Pages',
                        body:
                        'ScanAura may provide QR codes that direct '
                            'customers to a business page or related '
                            'ScanAura functionality. Businesses are '
                            'responsible for the content published through '
                            'their assigned QR codes and public pages.',
                      ),
                      _LegalSection(
                        title: '6. Third-Party Services',
                        body:
                        'ScanAura may provide links to third-party '
                            'services such as WhatsApp, Google, Instagram, '
                            'Facebook, YouTube, Google Maps, payment '
                            'services and other websites. Third-party '
                            'services operate independently and may have '
                            'their own terms and privacy policies.',
                      ),
                      _LegalSection(
                        title: '7. Business Content',
                        body:
                        'Businesses must not use ScanAura to publish '
                            'illegal, fraudulent, misleading, abusive, '
                            'infringing or otherwise prohibited content. '
                            'ScanAura may restrict or remove content or '
                            'accounts where reasonably necessary to protect '
                            'the platform, users or comply with applicable '
                            'law.',
                      ),
                      _LegalSection(
                        title: '8. Features and Availability',
                        body:
                        'ScanAura may add, modify, improve or discontinue '
                            'features as the platform develops. Temporary '
                            'service interruptions may occur because of '
                            'maintenance, technical issues, security '
                            'requirements or circumstances outside '
                            'ScanAura control.',
                      ),
                      _LegalSection(
                        title: '9. Subscriptions',
                        body:
                        'Some ScanAura features may require a paid '
                            'subscription. Applicable pricing, duration, '
                            'trial periods and subscription conditions will '
                            'be communicated at the time of purchase or '
                            'subscription.',
                      ),
                      _LegalSection(
                        title: '10. Account Suspension',
                        body:
                        'ScanAura may suspend or restrict an account or '
                            'public page where reasonably necessary because '
                            'of misuse, security concerns, violation of '
                            'these terms, non-payment or applicable legal '
                            'requirements.',
                      ),
                      _LegalSection(
                        title: '11. Customer Use',
                        body:
                        'Customers should verify business information, '
                            'pricing, availability and transaction details '
                            'directly with the relevant business before '
                            'making a purchase or relying on information '
                            'displayed on a business page.',
                      ),
                      _LegalSection(
                        title: '12. Contact',
                        body:
                        'Questions regarding these Terms & Conditions '
                            'can be directed to ScanAura Support at '
                            'scanauraofficial@gmail.com or '
                            '+91 7056222557.',
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ---------------------------------------------------------
                  // PRIVACY POLICY
                  // ---------------------------------------------------------
                  _legalCard(
                    context,
                    title: 'Privacy Policy',
                    icon: Icons.privacy_tip_outlined,
                    sections: const [
                      _LegalSection(
                        title: '1. Information We Collect',
                        body:
                        'Depending on how you use ScanAura, we may '
                            'process account information such as name, '
                            'mobile number, email address and authentication '
                            'information. Businesses may also provide '
                            'business information, catalogue data, images, '
                            'contact details and links.',
                      ),
                      _LegalSection(
                        title: '2. Business Information',
                        body:
                        'Businesses choose what information to publish '
                            'on their public ScanAura page. Information such '
                            'as business name, logo, address, contact '
                            'details, catalogue items, images and external '
                            'links may therefore be visible to visitors.',
                      ),
                      _LegalSection(
                        title: '3. How We Use Information',
                        body:
                        'We may use information to provide and maintain '
                            'ScanAura services, authenticate accounts, '
                            'manage business pages and QR codes, provide '
                            'support, manage subscriptions, provide '
                            'analytics, improve the platform, maintain '
                            'security and comply with applicable legal '
                            'requirements.',
                      ),
                      _LegalSection(
                        title: '4. QR and Usage Information',
                        body:
                        'ScanAura may process information relating to '
                            'QR scans, business-page visits and feature '
                            'usage in order to provide service functionality '
                            'and business analytics. Analytics may be used '
                            'in aggregated or operational form depending '
                            'on the feature.',
                      ),
                      _LegalSection(
                        title: '5. Uploaded Images and Content',
                        body:
                        'Businesses may upload logos, catalogue images '
                            'and gallery content. Such content may be stored '
                            'or delivered through third-party infrastructure '
                            'and cloud services used to operate ScanAura.',
                      ),
                      _LegalSection(
                        title: '6. We Do Not Sell Personal Information',
                        body:
                        'ScanAura does not sell users personal '
                            'information to third parties. We may use '
                            'service providers that help us operate the '
                            'platform, such as hosting, cloud storage, '
                            'email and other technical service providers.',
                      ),
                      _LegalSection(
                        title: '7. Third-Party Services',
                        body:
                        'ScanAura may link to or use third-party '
                            'services including Google, WhatsApp, Instagram, '
                            'Facebook, YouTube, Google Maps, cloud '
                            'infrastructure providers, email providers and '
                            'other service providers. Their own privacy '
                            'policies may apply when you interact with '
                            'their services.',
                      ),
                      _LegalSection(
                        title: '8. Customer and Business Communications',
                        body:
                        'When a customer contacts a business through '
                            'WhatsApp, phone, social media or another '
                            'external service, that communication may be '
                            'processed by the relevant business and/or '
                            'third-party service. ScanAura does not control '
                            'the privacy practices of independent third-party '
                            'platforms.',
                      ),
                      _LegalSection(
                        title: '9. Data Security',
                        body:
                        'ScanAura uses reasonable technical and '
                            'organisational measures designed to protect '
                            'information against unauthorised access, '
                            'misuse, alteration, disclosure or destruction. '
                            'No internet-based service can guarantee '
                            'absolute security.',
                      ),
                      _LegalSection(
                        title: '10. Data Retention',
                        body:
                        'Information may be retained for as long as '
                            'reasonably necessary to provide services, '
                            'maintain account and business records, '
                            'provide support, resolve disputes, comply '
                            'with legal obligations and protect the '
                            'security of the platform.',
                      ),
                      _LegalSection(
                        title: '11. Privacy Requests',
                        body:
                        'For questions or requests relating to personal '
                            'information or account data, contact ScanAura '
                            'Support using the contact details below.',
                      ),
                      _LegalSection(
                        title: '12. Contact',
                        body:
                        'Privacy-related questions can be sent to '
                            'scanauraofficial@gmail.com or '
                            '+91 7056222557.',
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ---------------------------------------------------------
                  // REFUND POLICY
                  // ---------------------------------------------------------
                  _legalCard(
                    context,
                    title: 'Refund Policy',
                    icon: Icons.currency_rupee_rounded,
                    sections: const [
                      _LegalSection(
                        title: '1. Subscription Services',
                        body:
                        'Refund eligibility depends on the applicable '
                            'subscription plan, payment terms and the '
                            'circumstances of the request.',
                      ),
                      _LegalSection(
                        title: '2. Contact Support',
                        body:
                        'If you believe you are eligible for a refund '
                            'or have a payment-related issue, contact '
                            'ScanAura Support with your account and payment '
                            'details.',
                      ),
                      _LegalSection(
                        title: '3. Service Issues',
                        body:
                        'If a technical issue materially affects an '
                            'active ScanAura service, contact support so '
                            'that the issue can be reviewed and an '
                            'appropriate resolution can be considered.',
                      ),
                      _LegalSection(
                        title: '4. Third-Party Payments',
                        body:
                        'Where a payment or transaction is processed '
                            'through a third-party provider, that provider '
                            'may have additional terms or procedures '
                            'applicable to the transaction.',
                      ),
                      _LegalSection(
                        title: '5. Contact',
                        body:
                        'For refund or payment support, contact '
                            'scanauraofficial@gmail.com or '
                            '+91 7056222557.',
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ---------------------------------------------------------
                  // FOOTER
                  // ---------------------------------------------------------
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'ScanAura',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Gurugram, Haryana, India',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Need help? Contact ScanAura Support.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Last updated: October 2026',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
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

  // =========================================================================
  // SECTION CARD
  // =========================================================================

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
        border: Border.all(
          color: AppColors.border,
        ),
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
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
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

  // =========================================================================
  // LEGAL CARD
  // =========================================================================

  Widget _legalCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required List<_LegalSection> sections,
      }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 4,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          18,
          0,
          18,
          18,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        leading: Icon(
          icon,
          color: AppColors.primary,
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          'Tap to read',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        children: [
          ...sections.map(
                (section) => _legalSection(
              context,
              section,
            ),
          ),
        ],
      ),
    );
  }

  Widget _legalSection(
      BuildContext context,
      _LegalSection section,
      ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(
        top: 14,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            section.body,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // CONTACT TILE
  // =========================================================================

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
              const Icon(
                Icons.chevron_right_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// LEGAL SECTION MODEL
// =============================================================================

class _LegalSection {
  const _LegalSection({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}