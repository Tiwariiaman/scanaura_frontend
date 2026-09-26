import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models/business_request.dart';
import '../presentation/providers/business_notifier.dart';
import '../presentation/providers/business_state.dart';
import 'business_review_screen.dart';

class BusinessDetailsScreen extends ConsumerStatefulWidget {
  const BusinessDetailsScreen({
    super.key,
    required this.businessName,
    required this.businessType,
    required this.phone,
    required this.whatsapp,
    required this.email,
    this.isEditMode = false,
  });

  final String businessName;
  final BusinessType businessType;
  final String phone;
  final String whatsapp;
  final String email;
  final bool isEditMode;

  @override
  ConsumerState<BusinessDetailsScreen> createState() =>
      _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState extends ConsumerState<BusinessDetailsScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _cityController = TextEditingController();

  final TextEditingController _stateController = TextEditingController();

  final TextEditingController _countryController = TextEditingController(
    text: 'India',
  );

  final TextEditingController _pincodeController = TextEditingController();

  final TextEditingController _websiteController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  final TextEditingController _upiController = TextEditingController();

  final TextEditingController _googleReviewController = TextEditingController();

  final TextEditingController _googleMapsController = TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  bool? _googleReviewEnabled;
  bool? _paymentEnabled;

  bool _isLoading = false;
  bool _isLoaded = false;

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBusinessFromState();
    });
  }
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
    _googleReviewController.dispose();
    _googleMapsController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD BUSINESS
  // ============================================================

  void _loadBusinessFromState() {
    if (!widget.isEditMode) {
      if (mounted) {
        setState(() {
          _isLoaded = true;
        });
      }
      return;
    }

    final state = ref.read(businessNotifierProvider);
    final business = state.business;

    if (business == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoaded = true;
        });
      }
      return;
    }

    _populateBusiness(business);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isLoaded = true;
      });
    }
  }

  // ============================================================
  // POPULATE BUSINESS
  // ============================================================

  void _populateBusiness(dynamic business) {
    _addressController.text = business.address ?? '';

    _cityController.text = business.city ?? '';

    _stateController.text = business.state ?? '';

    _countryController.text = business.country ?? 'India';

    _pincodeController.text = business.pincode ?? '';

    _websiteController.text = business.website ?? '';

    _descriptionController.text = business.description ?? '';

    _upiController.text = business.upiId ?? '';

    _googleReviewController.text = business.googleReviewUrl ?? '';

    _googleMapsController.text = business.googleMapsUrl ?? '';

    _googleReviewEnabled = business.googleReviewEnabled;

    _paymentEnabled = business.paymentEnabled;
  }

  // ============================================================
  // CONTINUE
  // ============================================================

  void _continue() {
    if (!_isLoaded) {
      return;
    }

    context.push(
      '/business/review',
      extra: BusinessReviewScreen(
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
        googleReviewUrl: _googleReviewController.text.trim(),
        googleMapsUrl: _googleMapsController.text.trim(),
        googleReviewEnabled: _googleReviewEnabled,
        paymentEnabled: _paymentEnabled,
        isEditMode: widget.isEditMode,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditMode ? 'Edit Business Details' : 'Business Details',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;

                  final horizontalPadding = width < 360
                      ? 16.0
                      : width < 600
                      ? 20.0
                      : 24.0;

                  final topPadding = width < 600 ? 16.0 : 24.0;

                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      topPadding,
                      horizontalPadding,
                      32,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ==================================================
                            // INTRO
                            // ==================================================
                            Text(
                              widget.isEditMode
                                  ? 'Update Your Details'
                                  : 'Complete Your Business',
                              textAlign: width < 600
                                  ? TextAlign.center
                                  : TextAlign.start,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              widget.isEditMode
                                  ? 'Update your business details below.'
                                  : 'Add a few more details to complete your ScanAura business profile.',
                              textAlign: width < 600
                                  ? TextAlign.center
                                  : TextAlign.start,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.45,
                              ),
                            ),

                            const SizedBox(height: 26),

                            // ==================================================
                            // LOCATION
                            // ==================================================
                            _section(
                              context,
                              title: 'Location',
                              icon: Icons.location_on_outlined,
                              children: [
                                _textField(
                                  controller: _addressController,
                                  label: 'Address',
                                  hint: 'Enter your business address',
                                  icon: Icons.home_outlined,
                                  maxLines: 2,
                                ),

                                const SizedBox(height: 16),

                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final compact = constraints.maxWidth < 500;

                                    if (compact) {
                                      return Column(
                                        children: [
                                          _textField(
                                            controller: _cityController,
                                            label: 'City',
                                            hint: 'Enter city',
                                            icon: Icons.location_city_outlined,
                                          ),

                                          const SizedBox(height: 16),

                                          _textField(
                                            controller: _stateController,
                                            label: 'State',
                                            hint: 'Enter state',
                                            icon: Icons.map_outlined,
                                          ),
                                        ],
                                      );
                                    }

                                    return Row(
                                      children: [
                                        Expanded(
                                          child: _textField(
                                            controller: _cityController,
                                            label: 'City',
                                            hint: 'Enter city',
                                            icon: Icons.location_city_outlined,
                                          ),
                                        ),

                                        const SizedBox(width: 16),

                                        Expanded(
                                          child: _textField(
                                            controller: _stateController,
                                            label: 'State',
                                            hint: 'Enter state',
                                            icon: Icons.map_outlined,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),

                                const SizedBox(height: 16),

                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final compact = constraints.maxWidth < 500;

                                    if (compact) {
                                      return Column(
                                        children: [
                                          _textField(
                                            controller: _countryController,
                                            label: 'Country',
                                            hint: 'Enter country',
                                            icon: Icons.public_outlined,
                                          ),

                                          const SizedBox(height: 16),

                                          _textField(
                                            controller: _pincodeController,
                                            label: 'Pincode',
                                            hint: 'Enter pincode',
                                            icon: Icons.pin_drop_outlined,
                                            keyboardType: TextInputType.number,
                                          ),
                                        ],
                                      );
                                    }

                                    return Row(
                                      children: [
                                        Expanded(
                                          child: _textField(
                                            controller: _countryController,
                                            label: 'Country',
                                            hint: 'Enter country',
                                            icon: Icons.public_outlined,
                                          ),
                                        ),

                                        const SizedBox(width: 16),

                                        Expanded(
                                          child: _textField(
                                            controller: _pincodeController,
                                            label: 'Pincode',
                                            hint: 'Enter pincode',
                                            icon: Icons.pin_drop_outlined,
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),

                                const SizedBox(height: 16),

                                _textField(
                                  controller: _googleMapsController,
                                  label: 'Google Maps Link',
                                  hint: 'Paste your Google Maps link',
                                  icon: Icons.map_outlined,
                                  keyboardType: TextInputType.url,
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  'Optional. Add your exact Google Maps link so customers can get directions to your business.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // ==================================================
                            // ONLINE PRESENCE
                            // ==================================================
                            _section(
                              context,
                              title: 'Online Presence',
                              icon: Icons.language_outlined,
                              children: [
                                _textField(
                                  controller: _googleReviewController,
                                  label: 'Google Review Link',
                                  hint: 'Paste your Google Review link',
                                  icon: Icons.rate_review_outlined,
                                  keyboardType: TextInputType.url,
                                ),

                                const SizedBox(height: 16),

                                _textField(
                                  controller: _websiteController,
                                  label: 'Website',
                                  hint: 'https://example.com',
                                  icon: Icons.public_outlined,
                                  keyboardType: TextInputType.url,
                                ),

                                const SizedBox(height: 16),

                                _textField(
                                  controller: _descriptionController,
                                  label: 'Business Description',
                                  hint: 'Tell customers about your business',
                                  icon: Icons.description_outlined,
                                  maxLines: 4,
                                  minLines: 3,
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // ==================================================
                            // PAYMENTS
                            // ==================================================
                            _section(
                              context,
                              title: 'Payments',
                              icon: Icons.payments_outlined,
                              children: [
                                _textField(
                                  controller: _upiController,
                                  label: 'UPI ID',
                                  hint: 'example@upi',
                                  icon: Icons.account_balance_wallet_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                ),

                                const SizedBox(height: 10),

                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme
                                        .colorScheme
                                        .surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.info_outline_rounded,
                                        size: 20,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'UPI payments are currently disabled. Payment features will be available soon.',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                                height: 1.4,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // ==================================================
                            // CONTINUE
                            // ==================================================
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: FilledButton.icon(
                                onPressed: _isLoaded ? _continue : null,
                                icon: const Icon(Icons.arrow_forward_rounded),
                                label: Text(
                                  widget.isEditMode
                                      ? 'Review Changes'
                                      : 'Continue',
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ==================================================
                            // BACK
                            // ==================================================
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                onPressed: () {
                                  if (Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop();
                                  } else {
                                    context.go('/business');
                                  }
                                },
                                child: const Text('Back'),
                              ),
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

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
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 21),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? minLines,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: minLines,
      textInputAction: maxLines > 1
          ? TextInputAction.newline
          : TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
