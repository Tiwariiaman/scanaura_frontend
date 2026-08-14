import 'package:flutter/material.dart';
import 'package:scanaura_frontend/features/business/data/models/business_request.dart';

import 'business_review_screen.dart';

class BusinessDetailsScreen extends StatefulWidget {
  const BusinessDetailsScreen({
    super.key,
    required this.businessName,
    required this.businessType,
    required this.phone,
    required this.whatsapp,
    required this.email,
  });

  final String businessName;
  final BusinessType businessType;
  final String phone;
  final String whatsapp;
  final String email;

  @override
  State<BusinessDetailsScreen> createState() =>
      _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState
    extends State<BusinessDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController(
    text: 'India',
  );
  final _pincodeController = TextEditingController();
  final _websiteController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _upiController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _pincodeController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    _upiController.dispose();

    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // We will connect this to the BusinessNotifier
    // after completing all onboarding fields.

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BusinessReviewScreen(
          businessName: widget.businessName,
          businessType: widget.businessType,
          phone: widget.phone,
          whatsapp: widget.whatsapp,
          email: widget.email,
          address: _addressController.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          country: _countryController.text.trim(),
          pincode: _pincodeController.text.trim(),
          website: _websiteController.text.trim(),
          description: _descriptionController.text.trim(),
          upiId: _upiController.text.trim(),
        ),
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
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 620,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    Text(
                      'Business Details',
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Add your location and other information '
                          'customers may need.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme
                            .colorScheme
                            .onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 28),

                    _buildProgressIndicator(context),

                    const SizedBox(height: 32),

                    Text(
                      'Location',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      textInputAction:
                      TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        hintText:
                        'Street, building or landmark',
                        prefixIcon: Icon(
                          Icons.location_on_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 500) {
                          return Column(
                            children: [
                              _cityField(),
                              const SizedBox(height: 16),
                              _stateField(),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: _cityField(),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _stateField(),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 500) {
                          return Column(
                            children: [
                              _countryField(),
                              const SizedBox(height: 16),
                              _pincodeField(),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: _countryField(),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _pincodeField(),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    Text(
                      'Online Presence',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _websiteController,
                      keyboardType:
                      TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'Website',
                        hintText:
                        'https://example.com',
                        prefixIcon: Icon(
                          Icons.language_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      maxLength: 1000,
                      decoration: const InputDecoration(
                        labelText: 'Business description',
                        hintText:
                        'Tell customers a little about your business...',
                        prefixIcon: Icon(
                          Icons.description_outlined,
                        ),
                        alignLabelWithHint: true,
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildBusinessSummary(context),
                    const SizedBox(height: 32),

                    Text(
                      'Payments',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _upiController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'UPI ID',
                        hintText: 'business@upi',
                        prefixIcon: Icon(
                          Icons.account_balance_wallet_outlined,
                        ),
                        helperText: 'Optional — you can add this later.',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return null;
                        }

                        if (!value.contains('@')) {
                          return 'Enter a valid UPI ID';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _continue,
                        icon: const Icon(
                          Icons.arrow_forward_rounded,
                        ),
                        label: const Text(
                          'Continue',
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
                        child: const Text(
                          'Back',
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cityField() {
    return TextFormField(
      controller: _cityController,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'City',
        prefixIcon: Icon(
          Icons.location_city_outlined,
        ),
      ),
    );
  }

  Widget _stateField() {
    return TextFormField(
      controller: _stateController,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'State',
        prefixIcon: Icon(
          Icons.map_outlined,
        ),
      ),
    );
  }

  Widget _countryField() {
    return TextFormField(
      controller: _countryController,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Country',
        prefixIcon: Icon(
          Icons.public_outlined,
        ),
      ),
    );
  }

  Widget _pincodeField() {
    return TextFormField(
      controller: _pincodeController,
      keyboardType: TextInputType.number,
      maxLength: 6,
      decoration: const InputDecoration(
        labelText: 'Pincode',
        counterText: '',
        prefixIcon: Icon(
          Icons.pin_drop_outlined,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return null;
        }

        if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
          return 'Enter a valid 6-digit pincode';
        }

        return null;
      },
    );
  }

  Widget _buildProgressIndicator(
      BuildContext context,
      ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius:
              BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius:
              BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: colorScheme
                  .surfaceContainerHighest,
              borderRadius:
              BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessSummary(
      BuildContext context,
      ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme
            .colorScheme
            .surfaceContainerLow,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: theme
              .colorScheme
              .outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            'Business Summary',
            style: theme.textTheme.titleMedium
                ?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _summaryRow(
            Icons.storefront_outlined,
            widget.businessName,
          ),
          const SizedBox(height: 8),
          _summaryRow(
            Icons.category_outlined,
            widget.businessType.displayName,
          ),
          const SizedBox(height: 8),
          _summaryRow(
            Icons.phone_outlined,
            widget.phone,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
      IconData icon,
      String value,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}