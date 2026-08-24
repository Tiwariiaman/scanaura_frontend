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
  ConsumerState<BusinessScreen> createState() =>
      _BusinessScreenState();
}

class _BusinessScreenState
    extends ConsumerState<BusinessScreen> {
  bool _loadingStarted = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBusiness();
    });
  }

  Future<void> _checkBusiness() async {
    if (_loadingStarted) {
      return;
    }

    _loadingStarted = true;

    await ref
        .read(businessNotifierProvider.notifier)
        .loadMyBusiness();

    if (!mounted) {
      return;
    }

    final state = ref.read(businessNotifierProvider);

    /*
     * BUSINESS EXISTS
     *
     * Do nothing.
     * The build method will display the business.
     */
    if (state.business != null) {
      return;
    }

    /*
     * NO BUSINESS
     *
     * Backend currently returns:
     *
     * Business not found.
     *
     * This is a normal onboarding state.
     */
    if (state.status == BusinessStatus.error &&
        state.errorMessage == 'Business not found.') {
      context.go('/business-onboarding');
      return;
    }

    /*
     * Unexpected error.
     *
     * Stay on this page and show retry.
     */
    setState(() {});
  }

  Future<void> _retry() async {
    setState(() {
      _loadingStarted = false;
    });

    await _checkBusiness();
  }

  Future<void> _pickAndUploadLogo() async {
    final business =
        ref.read(businessNotifierProvider).business;

    if (business == null) {
      _showMessage('Business details are not available.');
      return;
    }

    final result =
    await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null ||
        result.files.isEmpty) {
      return;
    }

    final file = result.files.single;

    final bytes = file.bytes;

    if (bytes == null || bytes.isEmpty) {
      _showMessage('Unable to read the selected image.');
      return;
    }

    try {
      _showLogoLoading(true);

      final compressed =
      await ImageCompressionHelper.compressLogo(
        bytes,
      );

      final uploadService =
      ref.read(imageUploadServiceProvider);

      final upload =
      await uploadService.uploadBusinessLogo(
        compressed,
        file.name,
      );

      final updatedRequest =
      BusinessRequest(
        businessName:
        business.businessName,
        businessType:
        _parseBusinessType(
          business.businessType,
        ),
        phone:
        business.phone,
        logoUrl:
        upload.imageUrl,
        whatsapp:
        business.whatsapp,
        email:
        business.email,
        address:
        business.address,
        city:
        business.city,
        state:
        business.state,
        country:
        business.country,
        pincode:
        business.pincode,
        website:
        business.website,
        description:
        business.description,
        upiId:
        business.upiId,
      );

      await ref
          .read(
        businessNotifierProvider.notifier,
      )
          .updateBusiness(
        updatedRequest,
      );

      if (!mounted) {
        return;
      }

      final state =
      ref.read(businessNotifierProvider);

      if (state.status ==
          BusinessStatus.success &&
          state.business != null) {
        _showMessage(
          'Business logo updated successfully.',
        );
      } else {
        _showMessage(
          state.errorMessage ??
              'Unable to save business logo.',
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    } finally {
      if (mounted) {
        _showLogoLoading(false);
      }
    }
  }

  bool _logoUploading = false;

  void _showLogoLoading(bool value) {
    setState(() {
      _logoUploading = value;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  BusinessType _parseBusinessType(
      String value,
      ) {
    final normalized =
    value.trim().toUpperCase();

    for (final type in BusinessType.values) {
      if (type.apiValue == normalized) {
        return type;
      }
    }

    return BusinessType.restaurant;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(businessNotifierProvider);

    /*
     * BUSINESS EXISTS
     */
    if (state.business != null) {
      return _buildBusinessPage(
        context,
        state.business!,
      );
    }

    /*
     * INITIAL CHECK / LOADING
     */
    if (state.status == BusinessStatus.loading ||
        state.status == BusinessStatus.initial) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    /*
     * ERROR
     */
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

  // ============================================================
  // BUSINESS PAGE
  // ============================================================

  Widget _buildBusinessPage(
      BuildContext context,
      dynamic business,
      ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Business'),
        actions: [
          IconButton(
            tooltip: 'Edit Business',
            onPressed: () {
              context.push(
                '/business-onboarding?edit=true',
              );
            },
            icon: const Icon(
              Icons.edit_outlined,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadingStarted = false;

          await ref
              .read(businessNotifierProvider.notifier)
              .loadMyBusiness();

          _loadingStarted = true;
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            // ==================================================
            // BUSINESS HEADER
            // ==================================================

            Card(
              elevation: 0,
              color: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.center,

                  children: [
                    // LOGO

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: _logoUploading
                              ? null
                              : _pickAndUploadLogo,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius:
                                  BorderRadius.circular(18),
                                ),
                                child: business.logoUrl != null &&
                                    business.logoUrl!
                                        .trim()
                                        .isNotEmpty
                                    ? ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(18),
                                  child: Image.network(
                                    business.logoUrl!,
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, _, _) {
                                      return Icon(
                                        Icons.storefront_rounded,
                                        size: 36,
                                        color:
                                        colorScheme.primary,
                                      );
                                    },
                                  ),
                                )
                                    : Icon(
                                  Icons.storefront_rounded,
                                  size: 36,
                                  color: colorScheme.primary,
                                ),
                              ),

                              if (_logoUploading)
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius:
                                    BorderRadius.circular(18),
                                  ),
                                  child: const Center(
                                    child:
                                    CircularProgressIndicator(),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Tap logo to change',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    // NAME + TYPE
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            business.businessName,
                            maxLines: 2,
                            overflow:
                            TextOverflow.ellipsis,
                            style: theme
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color:
                              colorScheme.surface,
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: Text(
                              _formatBusinessType(
                                business.businessType,
                              ),
                              style: theme
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // BUSINESS STATUS
            // ==================================================

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
                    style: theme
                        .textTheme
                        .bodyLarge
                        ?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ==================================================
            // CONTACT INFORMATION
            // ==================================================

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

            // ==================================================
            // ADDRESS
            // ==================================================

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

            const SizedBox(height: 16),

            // ==================================================
            // ONLINE & PAYMENT
            // ==================================================

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
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // ==================================================
            // DESCRIPTION
            // ==================================================

            if (_hasValue(business.description))
              _sectionCard(
                context,
                title: 'About Business',
                icon: Icons.description_outlined,
                child: Text(
                  business.description!,
                  style:
                  theme.textTheme.bodyLarge,
                ),
              ),

            const SizedBox(height: 24),

            // ==================================================
            // EDIT BUTTON
            // ==================================================

            SizedBox(
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
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

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
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 21,
                ),

                const SizedBox(width: 8),

                Text(
                  title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(
                    fontWeight: FontWeight.w700,
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

  // ============================================================
  // INFORMATION ROW
  // ============================================================

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

    return Padding(
      padding:
      const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: theme
                .colorScheme
                .onSurfaceVariant,
          ),

          const SizedBox(width: 12),

          SizedBox(
            width: 85,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(
                color: theme
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              value!,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR PAGE
  // ============================================================

  Widget _buildErrorPage(
      BuildContext context,
      String? message,
      ) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 56,
                color:
                theme.colorScheme.error,
              ),

              const SizedBox(height: 20),

              Text(
                'Unable to load business',
                style: theme
                    .textTheme
                    .titleLarge
                    ?.copyWith(
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
                icon: const Icon(
                  Icons.refresh_rounded,
                ),
                label: const Text(
                  'Retry',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  bool _hasValue(String? value) {
    return value != null &&
        value.trim().isNotEmpty;
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