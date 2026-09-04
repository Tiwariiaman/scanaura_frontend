import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models/business_request.dart';
import '../presentation/providers/business_notifier.dart';
import '../presentation/providers/business_state.dart';

class BusinessReviewScreen
    extends ConsumerStatefulWidget {
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
    required this.googleReviewUrl,
    this.googleReviewEnabled,
    this.paymentEnabled,
    this.isEditMode = false,
  });

  final String businessName;
  final BusinessType businessType;
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
  final String googleReviewUrl;
  final bool? googleReviewEnabled;
  final bool? paymentEnabled;

  final bool isEditMode;

  @override
  ConsumerState<BusinessReviewScreen>
  createState() =>
      _BusinessReviewScreenState();
}

class _BusinessReviewScreenState
    extends ConsumerState<
        BusinessReviewScreen> {
  bool _isSaving = false;

  // ============================================================
  // SAVE BUSINESS
  // ============================================================

  Future<void> _saveBusiness() async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final request =
    BusinessRequest(
      businessName:
      widget.businessName,
      businessType:
      widget.businessType,
      phone: widget.phone,

      whatsapp:
      widget.whatsapp.isEmpty
          ? null
          : widget.whatsapp,

      email:
      widget.email.isEmpty
          ? null
          : widget.email,

      address:
      widget.address.isEmpty
          ? null
          : widget.address,

      city:
      widget.city.isEmpty
          ? null
          : widget.city,

      state:
      widget.state.isEmpty
          ? null
          : widget.state,

      country:
      widget.country.isEmpty
          ? null
          : widget.country,

      pincode:
      widget.pincode.isEmpty
          ? null
          : widget.pincode,

      website:
      widget.website.isEmpty
          ? null
          : widget.website,

      description:
      widget.description.isEmpty
          ? null
          : widget.description,

      upiId:
      widget.upiId.isEmpty
          ? null
          : widget.upiId,

      googleReviewUrl:
      widget.googleReviewUrl.isEmpty
          ? null
          : widget.googleReviewUrl,

      googleReviewEnabled:
      widget.googleReviewEnabled,

      paymentEnabled:
      widget.paymentEnabled,
    );

    final notifier =
    ref.read(
      businessNotifierProvider
          .notifier,
    );

    if (widget.isEditMode) {
      await notifier.updateBusiness(
        request,
      );
    } else {
      await notifier.createBusiness(
        request,
      );
    }

    if (!mounted) {
      return;
    }

    final state =
    ref.read(
      businessNotifierProvider,
    );

    if (state.status ==
        BusinessStatus.success &&
        state.business != null) {
      setState(() {
        _isSaving = false;
      });

      if (widget.isEditMode) {
        context.go('/business');
      } else {
        context.go('/dashboard');
      }

      return;
    }

    setState(() {
      _isSaving = false;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        behavior:
        SnackBarBehavior.floating,
        content: Text(
          state.errorMessage ??
              (widget.isEditMode
                  ? 'Business update failed. Please try again.'
                  : 'Business creation failed. Please try again.'),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    final title =
    widget.isEditMode
        ? 'Review Changes'
        : 'Review Business';

    final description =
    widget.isEditMode
        ? 'Review your updated business information before saving.'
        : 'Review your business information before creating your ScanAura business.';

    final buttonText =
    widget.isEditMode
        ? 'Save Changes'
        : 'Create My Business';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style:
          const TextStyle(
            fontWeight:
            FontWeight.w700,
          ),
        ),
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (
              context,
              constraints,
              ) {
            final width =
                constraints.maxWidth;

            final horizontalPadding =
            width < 360
                ? 16.0
                : width < 600
                ? 20.0
                : 24.0;

            final topPadding =
            width < 600
                ? 16.0
                : 24.0;

            return SingleChildScrollView(
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior
                  .onDrag,
              padding:
              EdgeInsets.fromLTRB(
                horizontalPadding,
                topPadding,
                horizontalPadding,
                32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints:
                  const BoxConstraints(
                    maxWidth: 700,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                    children: [
                      // ==================================================
                      // INTRO
                      // ==================================================

                      Text(
                        widget.isEditMode
                            ? 'Review Your Changes'
                            : 'Almost there!',
                        textAlign:
                        width < 600
                            ? TextAlign.center
                            : TextAlign.start,
                        style: theme
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        description,
                        textAlign:
                        width < 600
                            ? TextAlign.center
                            : TextAlign.start,
                        style: theme
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                          color: theme
                              .colorScheme
                              .onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),

                      const SizedBox(
                        height: 26,
                      ),

                      // ==================================================
                      // BUSINESS
                      // ==================================================

                      _section(
                        context,
                        title: 'Business',
                        icon: Icons
                            .storefront_outlined,
                        children: [
                          _infoRow(
                            context,
                            'Business name',
                            widget.businessName,
                          ),
                          _infoRow(
                            context,
                            'Business type',
                            widget.businessType
                                .displayName,
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      // ==================================================
                      // CONTACT
                      // ==================================================

                      _section(
                        context,
                        title: 'Contact',
                        icon: Icons
                            .contact_phone_outlined,
                        children: [
                          _infoRow(
                            context,
                            'Phone',
                            widget.phone,
                          ),

                          if (widget
                              .whatsapp
                              .isNotEmpty)
                            _infoRow(
                              context,
                              'WhatsApp',
                              widget.whatsapp,
                            ),

                          if (widget
                              .email
                              .isNotEmpty)
                            _infoRow(
                              context,
                              'Email',
                              widget.email,
                            ),
                        ],
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      // ==================================================
                      // LOCATION
                      // ==================================================

                      _section(
                        context,
                        title: 'Location',
                        icon: Icons
                            .location_on_outlined,
                        children: [
                          if (widget
                              .address
                              .isNotEmpty)
                            _infoRow(
                              context,
                              'Address',
                              widget.address,
                            ),

                          if (widget
                              .city
                              .isNotEmpty)
                            _infoRow(
                              context,
                              'City',
                              widget.city,
                            ),

                          if (widget
                              .state
                              .isNotEmpty)
                            _infoRow(
                              context,
                              'State',
                              widget.state,
                            ),

                          if (widget
                              .country
                              .isNotEmpty)
                            _infoRow(
                              context,
                              'Country',
                              widget.country,
                            ),

                          if (widget
                              .pincode
                              .isNotEmpty)
                            _infoRow(
                              context,
                              'Pincode',
                              widget.pincode,
                            ),
                        ],
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      // ==================================================
                      // ADDITIONAL INFORMATION
                      // ==================================================

                      _section(
                        context,
                        title:
                        'Additional Information',
                        icon: Icons
                            .info_outline_rounded,
                        children: [
                          if (widget
                              .googleReviewUrl
                              .isNotEmpty)
                            _infoRow(
                              context,
                              'Google Review Link',
                              widget.googleReviewUrl,
                            ),

                          if (widget
                              .description
                              .isNotEmpty)
                            _infoRow(
                              context,
                              'Description',
                              widget.description,
                              allowMultiline:
                              true,
                            ),

                          if (widget
                              .upiId
                              .isNotEmpty)
                            _infoRow(
                              context,
                              'UPI ID',
                              widget.upiId,
                            ),
                        ],
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      // ==================================================
                      // CONFIRMATION MESSAGE
                      // ==================================================

                      Container(
                        width:
                        double.infinity,
                        padding:
                        const EdgeInsets.all(
                          16,
                        ),
                        decoration:
                        BoxDecoration(
                          color: theme
                              .colorScheme
                              .primaryContainer,
                          borderRadius:
                          BorderRadius.circular(
                            16,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            Icon(
                              Icons
                                  .check_circle_outline_rounded,
                              color: theme
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            Expanded(
                              child: Text(
                                widget.isEditMode
                                    ? 'Your existing business information will be updated with the changes shown above.'
                                    : 'Your business will be created using the information shown above.',
                                style: theme
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                  color: theme
                                      .colorScheme
                                      .onPrimaryContainer,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      // ==================================================
                      // SAVE
                      // ==================================================

                      SizedBox(
                        width:
                        double.infinity,
                        height: 54,
                        child:
                        FilledButton.icon(
                          onPressed:
                          _isSaving
                              ? null
                              : _saveBusiness,
                          icon: _isSaving
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                            CircularProgressIndicator(
                              strokeWidth:
                              2.5,
                            ),
                          )
                              : Icon(
                            widget
                                .isEditMode
                                ? Icons
                                .save_outlined
                                : Icons
                                .check_rounded,
                          ),
                          label: Text(
                            _isSaving
                                ? widget.isEditMode
                                ? 'Saving Changes...'
                                : 'Creating Business...'
                                : buttonText,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      // ==================================================
                      // BACK
                      // ==================================================

                      SizedBox(
                        width:
                        double.infinity,
                        height: 48,
                        child:
                        OutlinedButton(
                          onPressed:
                          _isSaving
                              ? null
                              : () {
                            Navigator.of(
                              context,
                            ).pop();
                          },
                          child:
                          const Text(
                            'Back',
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 24,
                      ),
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
    final theme =
    Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding:
        const EdgeInsets.all(18),
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

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                    style: theme
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 14,
            ),

            ...children,
          ],
        ),
      ),
    );
  }

  // ============================================================
  // RESPONSIVE INFO ROW
  // ============================================================

  Widget _infoRow(
      BuildContext context,
      String label,
      String value, {
        bool allowMultiline = false,
      }) {
    final theme =
    Theme.of(context);

    return LayoutBuilder(
      builder:
          (context, constraints) {
        final compact =
            constraints.maxWidth <
                460;

        if (compact) {
          return Padding(
            padding:
            const EdgeInsets.only(
              bottom: 14,
            ),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment:
                  Alignment.center,
                  decoration:
                  BoxDecoration(
                    color: theme
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius:
                    BorderRadius.circular(
                      9,
                    ),
                  ),
                  child: Icon(
                    Icons
                        .arrow_right_rounded,
                    size: 18,
                    color: theme
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Text(
                        label,
                        style: theme
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color: theme
                              .colorScheme
                              .onSurfaceVariant,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),

                      const SizedBox(
                        height: 3,
                      ),

                      Text(
                        value.isEmpty
                            ? '—'
                            : value,
                        softWrap: true,
                        maxLines:
                        allowMultiline
                            ? null
                            : 3,
                        overflow:
                        allowMultiline
                            ? TextOverflow
                            .visible
                            : TextOverflow
                            .ellipsis,
                        style: theme
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          fontWeight:
                          FontWeight.w600,
                          height: 1.4,
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
          padding:
          const EdgeInsets.only(
            bottom: 12,
          ),
          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  label,
                  style: theme
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    color: theme
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Text(
                  value.isEmpty
                      ? '—'
                      : value,
                  softWrap: true,
                  maxLines:
                  allowMultiline
                      ? null
                      : 4,
                  overflow:
                  allowMultiline
                      ? TextOverflow
                      .visible
                      : TextOverflow
                      .ellipsis,
                  style: theme
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    fontWeight:
                    FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
