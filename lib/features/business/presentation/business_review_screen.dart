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

  final bool isEditMode;

  @override
  ConsumerState<BusinessReviewScreen>
  createState() =>
      _BusinessReviewScreenState();
}

class _BusinessReviewScreenState
    extends ConsumerState<BusinessReviewScreen> {
  bool _isSaving = false;

  Future<void> _saveBusiness() async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final request = BusinessRequest(
      businessName:
      widget.businessName,
      businessType:
      widget.businessType,
      phone:
      widget.phone,
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
    );

    final notifier =
    ref.read(
      businessNotifierProvider.notifier,
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
        // Editing:
        // return to the Business page.
        context.go('/business');
      } else {
        // Creating:
        // continue to Dashboard.
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
        content: Text(
          state.errorMessage ??
              (widget.isEditMode
                  ? 'Business update failed. Please try again.'
                  : 'Business creation failed. Please try again.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(title),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 700,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isEditMode
                        ? 'Review Your Changes'
                        : 'Almost there!',
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
                    style: theme
                        .textTheme
                        .bodyLarge
                        ?.copyWith(
                      color: theme
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

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
                      if (widget.whatsapp
                          .isNotEmpty)
                        _infoRow(
                          context,
                          'WhatsApp',
                          widget.whatsapp,
                        ),
                      if (widget.email
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

                  _section(
                    context,
                    title: 'Location',
                    icon: Icons
                        .location_on_outlined,
                    children: [
                      if (widget.address
                          .isNotEmpty)
                        _infoRow(
                          context,
                          'Address',
                          widget.address,
                        ),
                      if (widget.city
                          .isNotEmpty)
                        _infoRow(
                          context,
                          'City',
                          widget.city,
                        ),
                      if (widget.state
                          .isNotEmpty)
                        _infoRow(
                          context,
                          'State',
                          widget.state,
                        ),
                      if (widget.country
                          .isNotEmpty)
                        _infoRow(
                          context,
                          'Country',
                          widget.country,
                        ),
                      if (widget.pincode
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

                  _section(
                    context,
                    title:
                    'Additional Information',
                    icon: Icons
                        .info_outline_rounded,
                    children: [
                      if (widget.website
                          .isNotEmpty)
                        _infoRow(
                          context,
                          'Website',
                          widget.website,
                        ),
                      if (widget.description
                          .isNotEmpty)
                        _infoRow(
                          context,
                          'Description',
                          widget.description,
                        ),
                      if (widget.upiId
                          .isNotEmpty)
                        _infoRow(
                          context,
                          'UPI ID',
                          widget.upiId,
                        ),
                    ],
                  ),

                  const SizedBox(
                    height: 28,
                  ),

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
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

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
                        widget.isEditMode
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
                      child: const Text(
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
    final theme =
    Theme.of(context);

    return Card(
      elevation: 0,
      child: Padding(
        padding:
        const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  title,
                  style: theme
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
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
    final theme =
    Theme.of(context);

    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
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
          Expanded(
            child: Text(
              value.isEmpty
                  ? '—'
                  : value,
              style: theme
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}