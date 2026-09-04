import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/utils/image_compression_helper.dart';
import '../data/models/business_request.dart';
import 'providers/business_notifier.dart';
import 'providers/business_state.dart';

class BusinessScreen extends ConsumerStatefulWidget {
  const BusinessScreen({super.key});

  @override
  ConsumerState<BusinessScreen> createState() => _BusinessScreenState();
}

class _BusinessScreenState extends ConsumerState<BusinessScreen> {
  bool _loadingStarted = false;
  bool _logoUploading = false;
  bool _googleReviewUpdating = false;
  bool _paymentUpdating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBusiness();
    });
  }

  Future<void> _checkBusiness() async {
    if (_loadingStarted) return;

    _loadingStarted = true;

    await ref.read(businessNotifierProvider.notifier).loadMyBusiness();

    if (!mounted) return;

    final state = ref.read(businessNotifierProvider);

    if (state.business != null) return;

    if (state.status == BusinessStatus.error &&
        state.errorMessage == 'Business not found.') {
      context.go('/business-onboarding');
      return;
    }

    setState(() {});
  }

  Future<void> _retry() async {
    setState(() {
      _loadingStarted = false;
    });
    await _checkBusiness();
  }

  Future<void> _refreshBusiness() async {
    await ref.read(businessNotifierProvider.notifier).loadMyBusiness();
  }

  Future<void> _pickAndUploadLogo() async {
    if (_logoUploading) return;

    final business = ref.read(businessNotifierProvider).business;

    if (business == null) {
      _showMessage('Business details are not available.');
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    final bytes = file.bytes;

    if (bytes == null || bytes.isEmpty) {
      _showMessage('Unable to read the selected image.');
      return;
    }

    try {
      _showLogoLoading(true);

      final compressed =
      await ImageCompressionHelper.compressLogo(bytes);

      final uploadService = ref.read(imageUploadServiceProvider);

      final upload = await uploadService.uploadBusinessLogo(
        compressed,
        file.name,
      );

      final businessType = _parseBusinessType(business.businessType);

      if (businessType == null) {
        throw Exception('Unable to determine business type.');
      }

      // IMPORTANT:
      // Preserve every existing customer-feature setting while changing
      // only the logo. This prevents logo updates from resetting toggles.
      final updatedRequest = BusinessRequest(
        businessName: business.businessName,
        businessType: businessType,
        phone: business.phone,
        logoUrl: upload.imageUrl,
        whatsapp: business.whatsapp,
        email: business.email,
        address: business.address,
        city: business.city,
        state: business.state,
        country: business.country,
        pincode: business.pincode,
        website: business.website,
        description: business.description,
        upiId: business.upiId,
        googleReviewUrl: business.googleReviewUrl,
        googleReviewEnabled: business.googleReviewEnabled,
        paymentEnabled: business.paymentEnabled,
      );

      await ref
          .read(businessNotifierProvider.notifier)
          .updateBusiness(updatedRequest);

      if (!mounted) return;

      final state = ref.read(businessNotifierProvider);

      if (state.status == BusinessStatus.success &&
          state.business != null) {
        // Re-read from the backend so the UI reflects persisted state.
        await _refreshBusiness();

        if (!mounted) return;
        _showMessage('Business logo updated successfully.');
      } else {
        _showMessage(
          state.errorMessage ?? 'Unable to save business logo.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        _showLogoLoading(false);
      }
    }
  }

  Future<void> _setGoogleReviewEnabled(bool value) async {
    if (_googleReviewUpdating) return;

    final business = ref.read(businessNotifierProvider).business;

    if (business == null) {
      _showMessage('Business details are not available.');
      return;
    }

    if (value && !_hasValue(business.googleReviewUrl)) {
      _showMessage('Add your Google Review link first.');
      return;
    }

    await _updateCustomerFeature(
      value: value,
      feature: 'googleReview',
    );
  }

  Future<void> _setPaymentEnabled(bool value) async {
    if (_paymentUpdating) return;

    final business = ref.read(businessNotifierProvider).business;

    if (business == null) {
      _showMessage('Business details are not available.');
      return;
    }

    if (value && !_hasValue(business.upiId)) {
      _showMessage('Add your UPI ID first.');
      return;
    }

    await _updateCustomerFeature(
      value: value,
      feature: 'payment',
    );
  }

  Future<void> _updateCustomerFeature({
    required bool value,
    required String feature,
  }) async {
    final isGoogleReview = feature == 'googleReview';

    setState(() {
      if (isGoogleReview) {
        _googleReviewUpdating = true;
      } else {
        _paymentUpdating = true;
      }
    });

    try {
      final business =
          ref.read(businessNotifierProvider).business;

      if (business == null) {
        _showMessage('Business details are not available.');
        return;
      }

      final businessType = _parseBusinessType(business.businessType);

      if (businessType == null) {
        _showMessage('Unable to determine business type.');
        return;
      }

      final updatedRequest = BusinessRequest(
        businessName: business.businessName,
        businessType: businessType,
        phone: business.phone,
        logoUrl: business.logoUrl,
        whatsapp: business.whatsapp,
        email: business.email,
        address: business.address,
        city: business.city,
        state: business.state,
        country: business.country,
        pincode: business.pincode,
        website: business.website,
        description: business.description,
        upiId: business.upiId,
        googleReviewUrl: business.googleReviewUrl,
        googleReviewEnabled:
        isGoogleReview ? value : business.googleReviewEnabled,
        paymentEnabled:
        isGoogleReview ? business.paymentEnabled : value,
      );

      await ref
          .read(businessNotifierProvider.notifier)
          .updateBusiness(updatedRequest);

      if (!mounted) return;

      final state = ref.read(businessNotifierProvider);

      if (state.status != BusinessStatus.success ||
          state.business == null) {
        _showMessage(
          state.errorMessage ?? 'Unable to update the setting.',
        );
        return;
      }

      // Never rely only on optimistic/local state.
      // Fetch the saved record again so the switch represents the backend.
      await _refreshBusiness();

      if (!mounted) return;

      final refreshed = ref.read(businessNotifierProvider).business;

      final persistedValue = isGoogleReview
          ? refreshed?.googleReviewEnabled == true
          : refreshed?.paymentEnabled == true;

      if (persistedValue != value) {
        _showMessage(
          'The setting could not be saved. Please try again.',
        );
        await _refreshBusiness();
        return;
      }

      _showMessage(
        isGoogleReview
            ? (value
            ? 'Google Reviews enabled.'
            : 'Google Reviews disabled.')
            : (value
            ? 'UPI Payments enabled.'
            : 'UPI Payments disabled.'),
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
      );

      // Restore the UI from the backend after any failure.
      await _refreshBusiness();
    } finally {
      if (mounted) {
        setState(() {
          if (isGoogleReview) {
            _googleReviewUpdating = false;
          } else {
            _paymentUpdating = false;
          }
        });
      }
    }
  }

  void _showLogoLoading(bool value) {
    if (!mounted) return;
    setState(() {
      _logoUploading = value;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  BusinessType? _parseBusinessType(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final normalized = value.trim().toUpperCase();

    for (final type in BusinessType.values) {
      if (type.name.toUpperCase() == normalized) {
        return type;
      }

      if (type.apiValue == normalized) {
        return type;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(businessNotifierProvider);

    if (state.business != null) {
      return _buildBusinessPage(
        context,
        state.business!,
      );
    }

    if (state.status == BusinessStatus.loading ||
        state.status == BusinessStatus.initial) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.status == BusinessStatus.error) {
      return _buildErrorPage(
        context,
        state.errorMessage,
      );
    }

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildBusinessPage(
      BuildContext context,
      dynamic business,
      ) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Business',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit Business',
            onPressed: () {
              context.push('/business-onboarding?edit=true');
            },
            icon: const Icon(Icons.edit_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshBusiness,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                32,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1100,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildBusinessHeader(
                          context,
                          business,
                        ),
                        const SizedBox(height: 20),

                        _sectionCard(
                          context,
                          title: 'Business Status',
                          icon: Icons.verified_outlined,
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: business.active == true
                                      ? Colors.green
                                      : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                business.active == true
                                    ? 'Active'
                                    : 'Inactive',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        _sectionCard(
                          context,
                          title: 'Contact Information',
                          icon: Icons.contact_phone_outlined,
                          child: Column(
                            children: [
                              _infoRow(
                                context,
                                Icons.phone_outlined,
                                'Phone',
                                business.phone,
                              ),
                              if (_hasValue(business.whatsapp))
                                _infoRow(
                                  context,
                                  Icons.chat_outlined,
                                  'WhatsApp',
                                  business.whatsapp,
                                ),
                              if (_hasValue(business.email))
                                _infoRow(
                                  context,
                                  Icons.email_outlined,
                                  'Email',
                                  business.email,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (_hasAddress(business))
                          _sectionCard(
                            context,
                            title: 'Address',
                            icon: Icons.location_on_outlined,
                            child: Column(
                              children: [
                                if (_hasValue(business.address))
                                  _infoRow(
                                    context,
                                    Icons.home_outlined,
                                    'Address',
                                    business.address,
                                  ),
                                if (_hasValue(business.city))
                                  _infoRow(
                                    context,
                                    Icons.location_city_outlined,
                                    'City',
                                    business.city,
                                  ),
                                if (_hasValue(business.state))
                                  _infoRow(
                                    context,
                                    Icons.map_outlined,
                                    'State',
                                    business.state,
                                  ),
                                if (_hasValue(business.country))
                                  _infoRow(
                                    context,
                                    Icons.public_outlined,
                                    'Country',
                                    business.country,
                                  ),
                                if (_hasValue(business.pincode))
                                  _infoRow(
                                    context,
                                    Icons.pin_drop_outlined,
                                    'Pincode',
                                    business.pincode,
                                  ),
                              ],
                            ),
                          ),
                        if (_hasAddress(business))
                          const SizedBox(height: 16),

                        if (_hasValue(business.website) ||
                            _hasValue(business.upiId))
                          _sectionCard(
                            context,
                            title: 'Additional Information',
                            icon: Icons.info_outline_rounded,
                            child: Column(
                              children: [
                                if (_hasValue(business.website))
                                  _infoRow(
                                    context,
                                    Icons.language_outlined,
                                    'Website',
                                    business.website,
                                  ),
                                if (_hasValue(business.upiId))
                                  _infoRow(
                                    context,
                                    Icons.account_balance_wallet_outlined,
                                    'UPI ID',
                                    business.upiId,
                                  ),
                                if (_hasValue(business.googleReviewUrl))
                                  _infoRow(
                                    context,
                                    Icons.rate_review_outlined,
                                    'Google Review Link',
                                    business.googleReviewUrl,
                                  ),
                              ],
                            ),
                          ),
                        if (_hasValue(business.website) ||
                            _hasValue(business.upiId))
                          const SizedBox(height: 16),

                        _buildCustomerFeatures(
                          context,
                          business,
                        ),
                        const SizedBox(height: 16),

                        if (_hasValue(business.description))
                          _sectionCard(
                            context,
                            title: 'About Business',
                            icon: Icons.description_outlined,
                            child: Text(
                              business.description!,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.5,
                              ),
                            ),
                          ),
                        if (_hasValue(business.description))
                          const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton.icon(
                            onPressed: () {
                              context.push(
                                '/business-onboarding?edit=true',
                              );
                            },
                            icon: const Icon(
                              Icons.edit_outlined,
                            ),
                            label: const Text(
                              'Edit Business',
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCustomerFeatures(
      BuildContext context,
      dynamic business,
      ) {
    return _sectionCard(
      context,
      title: 'Customer Features',
      icon: Icons.auto_awesome_outlined,
      child: Column(
        children: [
          _buildFeatureTile(
            context,
            icon: Icons.rate_review_outlined,
            title: 'Google Reviews',
            description: _hasValue(business.googleReviewUrl)
                ? (business.googleReviewEnabled == true
                ? 'Showing Review Us button to customers.'
                : 'Review button is hidden from customers.')
                : 'Add your Google Review link first.',
            enabled: _hasValue(business.googleReviewUrl),
            value: business.googleReviewEnabled == true,
            loading: _googleReviewUpdating,
            onChanged: _setGoogleReviewEnabled,
          ),
          const SizedBox(height: 12),
          _buildFeatureTile(
            context,
            icon: Icons.account_balance_wallet_outlined,
            title: 'UPI Payments',
            description: _hasValue(business.upiId)
                ? (business.paymentEnabled == true
                ? 'Pay via UPI is available to customers.'
                : 'Payment option is hidden from customers.')
                : 'Add your UPI ID first.',
            enabled: _hasValue(business.upiId),
            value: business.paymentEnabled == true,
            loading: _paymentUpdating,
            onChanged: _setPaymentEnabled,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
        required bool enabled,
        required bool value,
        required bool loading,
        required ValueChanged<bool> onChanged,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: enabled
                  ? colorScheme.primaryContainer
                  : colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              enabled ? icon : Icons.lock_outline_rounded,
              color: enabled
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (loading)
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    else
                      Switch.adaptive(
                        value: value,
                        onChanged: enabled ? onChanged : null,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                _buildFeatureStatus(
                  context,
                  enabled: enabled,
                  value: value,
                  loading: loading,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureStatus(
      BuildContext context, {
        required bool enabled,
        required bool value,
        required bool loading,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String text;
    IconData icon;

    if (!enabled) {
      text = 'Setup required';
      icon = Icons.lock_outline_rounded;
    } else if (loading) {
      text = 'Saving...';
      icon = Icons.sync_rounded;
    } else if (value) {
      text = 'Active on public page';
      icon = Icons.check_circle_outline_rounded;
    } else {
      text = 'Not shown to customers';
      icon = Icons.visibility_off_outlined;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: enabled && value
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessHeader(
      BuildContext context,
      dynamic business,
      ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 500;

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildLogo(
                    context,
                    business,
                    size: 84,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    business.businessName,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _businessTypeChip(
                    context,
                    business.businessType,
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildLogo(
                  context,
                  business,
                  size: 84,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business.businessName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _businessTypeChip(
                        context,
                        business.businessType,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogo(
      BuildContext context,
      dynamic business, {
        required double size,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _logoUploading ? null : _pickAndUploadLogo,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(size * 0.22),
                ),
                child: business.logoUrl != null &&
                    business.logoUrl!.trim().isNotEmpty
                    ? ClipRRect(
                  borderRadius:
                  BorderRadius.circular(size * 0.22),
                  child: Image.network(
                    business.logoUrl!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) {
                      return Icon(
                        Icons.storefront_rounded,
                        size: size * 0.5,
                        color: colorScheme.primary,
                      );
                    },
                  ),
                )
                    : Icon(
                  Icons.storefront_rounded,
                  size: size * 0.5,
                  color: colorScheme.primary,
                ),
              ),
              if (_logoUploading)
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(size * 0.22),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _logoUploading ? 'Updating logo...' : 'Tap logo to change',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _businessTypeChip(
      BuildContext context,
      String type,
      ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _formatBusinessType(type),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _sectionCard(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Widget child,
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
                Icon(
                  icon,
                  size: 21,
                ),
                const SizedBox(width: 8),
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
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
      BuildContext context,
      IconData icon,
      String label,
      String? value,
      ) {
    if (!_hasValue(value)) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 420;

        if (compact) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        value!,
                        softWrap: true,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 85,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value!,
                  softWrap: true,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorPage(
      BuildContext context,
      String? message,
      ) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_off_rounded,
                    size: 56,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Unable to load business',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message ??
                        'Something went wrong. Please try again.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _retry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  bool _hasAddress(dynamic business) {
    return _hasValue(business.address) ||
        _hasValue(business.city) ||
        _hasValue(business.state) ||
        _hasValue(business.country) ||
        _hasValue(business.pincode);
  }

  String _formatBusinessType(dynamic type) {
    final value = type.toString().split('.').last;

    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
          ? word
          : '${word[0].toUpperCase()}'
          '${word.substring(1).toLowerCase()}',
    )
        .join(' ');
  }
}
