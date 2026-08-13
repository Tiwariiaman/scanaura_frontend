import 'package:flutter/material.dart';

class BusinessReviewScreen extends StatelessWidget {
  const BusinessReviewScreen({
    super.key,
    required this.businessName,
    required this.businessType,
    required this.phone,
    required this.whatsapp,
    required this.email,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.website,
    required this.description,
    required this.upiId,
  });

  final String businessName;
  final String businessType;
  final String phone;
  final String whatsapp;
  final String email;
  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final String website;
  final String description;
  final String upiId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Business'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 700,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Almost there!',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Review your business information before creating your ScanAura business.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 28),

                  _section(
                    context,
                    title: 'Business',
                    icon: Icons.storefront_outlined,
                    children: [
                      _infoRow(
                        context,
                        'Business name',
                        businessName,
                      ),
                      _infoRow(
                        context,
                        'Business type',
                        businessType,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _section(
                    context,
                    title: 'Contact',
                    icon: Icons.contact_phone_outlined,
                    children: [
                      _infoRow(
                        context,
                        'Phone',
                        phone,
                      ),
                      if (whatsapp.isNotEmpty)
                        _infoRow(
                          context,
                          'WhatsApp',
                          whatsapp,
                        ),
                      if (email.isNotEmpty)
                        _infoRow(
                          context,
                          'Email',
                          email,
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _section(
                    context,
                    title: 'Location',
                    icon: Icons.location_on_outlined,
                    children: [
                      if (address.isNotEmpty)
                        _infoRow(
                          context,
                          'Address',
                          address,
                        ),
                      if (city.isNotEmpty)
                        _infoRow(
                          context,
                          'City',
                          city,
                        ),
                      if (state.isNotEmpty)
                        _infoRow(
                          context,
                          'State',
                          state,
                        ),
                      if (country.isNotEmpty)
                        _infoRow(
                          context,
                          'Country',
                          country,
                        ),
                      if (pincode.isNotEmpty)
                        _infoRow(
                          context,
                          'Pincode',
                          pincode,
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _section(
                    context,
                    title: 'Additional Information',
                    icon: Icons.info_outline_rounded,
                    children: [
                      if (website.isNotEmpty)
                        _infoRow(
                          context,
                          'Website',
                          website,
                        ),
                      if (description.isNotEmpty)
                        _infoRow(
                          context,
                          'Description',
                          description,
                        ),
                      if (upiId.isNotEmpty)
                        _infoRow(
                          context,
                          'UPI ID',
                          upiId,
                        ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Your business will be created using the information shown above.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                              theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: () {
                        // API connection comes in the next step.
                      },
                      icon: const Icon(
                        Icons.check_rounded,
                      ),
                      label: const Text(
                        'Create Business',
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Back'),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(
      BuildContext context, {
        required String title,
        required IconData icon,
        required List<Widget> children,
      }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
      BuildContext context,
      String label,
      String value,
      ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}