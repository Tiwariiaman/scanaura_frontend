import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scanaura_frontend/features/business/data/models/business_request.dart';
import 'package:scanaura_frontend/features/business/data/models/business_response.dart';

import '../presentation/providers/business_notifier.dart';
import 'business_review_screen.dart';

class BusinessDetailsScreen
    extends ConsumerStatefulWidget {
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
  ConsumerState<BusinessDetailsScreen>
  createState() =>
      _BusinessDetailsScreenState();
}

class _BusinessDetailsScreenState
    extends ConsumerState<
        BusinessDetailsScreen> {
  final _formKey =
  GlobalKey<FormState>();

  final _addressController =
  TextEditingController();

  final _cityController =
  TextEditingController();

  final _stateController =
  TextEditingController();

  final _countryController =
  TextEditingController(
    text: 'India',
  );

  final _pincodeController =
  TextEditingController();

  final _websiteController =
  TextEditingController();

  final _descriptionController =
  TextEditingController();

  final _upiController =
  TextEditingController();

  final _googleReviewController =
  TextEditingController();

  bool? _googleReviewEnabled;
  bool? _paymentEnabled;

  bool _loadingBusiness = false;
  bool _loadedBusiness = false;

  @override
  void initState() {
    super.initState();

    if (widget.isEditMode) {
      Future.microtask(
        _loadExistingBusiness,
      );
    }
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

    super.dispose();
  }

  // ============================================================
  // LOAD EXISTING BUSINESS
  // ============================================================

  Future<void> _loadExistingBusiness() async {
    if (_loadedBusiness) {
      return;
    }

    setState(() {
      _loadingBusiness = true;
    });

    await ref
        .read(
      businessNotifierProvider.notifier,
    )
        .loadMyBusiness();

    if (!mounted) {
      return;
    }

    final state =
    ref.read(
      businessNotifierProvider,
    );

    final business = state.business;

    if (business != null) {
      _populateBusiness(business);
    }

    setState(() {
      _loadingBusiness = false;
      _loadedBusiness = true;
    });
  }

  void _populateBusiness(
      BusinessResponse business,
      ) {
    _addressController.text =
        business.address ?? '';

    _cityController.text =
        business.city ?? '';

    _stateController.text =
        business.state ?? '';

    _countryController.text =
        business.country ?? 'India';

    _pincodeController.text =
        business.pincode ?? '';

    _websiteController.text =
        business.website ?? '';

    _descriptionController.text =
        business.description ?? '';

    _upiController.text =
        business.upiId ?? '';

    _googleReviewController.text =
        business.googleReviewUrl ?? '';

    _googleReviewEnabled =
        business.googleReviewEnabled;

    _paymentEnabled =
        business.paymentEnabled;
  }

  // ============================================================
  // CONTINUE
  // ============================================================

  void _continue() {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            BusinessReviewScreen(
              businessName:
              widget.businessName,
              businessType:
              widget.businessType,
              phone: widget.phone,
              whatsapp: widget.whatsapp,
              email: widget.email,
              address:
              _addressController.text
                  .trim(),
              city:
              _cityController.text
                  .trim(),
              state:
              _stateController.text
                  .trim(),
              country:
              _countryController.text
                  .trim(),
              pincode:
              _pincodeController.text
                  .trim(),
              website:
              _websiteController.text
                  .trim(),
              description:
              _descriptionController.text
                  .trim(),
              upiId:
              _upiController.text
                  .trim(),
              googleReviewUrl:
              _googleReviewController.text
                  .trim(),
              googleReviewEnabled:
              _googleReviewEnabled,
              paymentEnabled:
              _paymentEnabled,
              isEditMode:
              widget.isEditMode,
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

    if (widget.isEditMode &&
        _loadingBusiness) {
      return const Scaffold(
        body: Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditMode
              ? 'Edit Business Details'
              : 'Business Details',
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
                    maxWidth: 620,
                  ),
                  child: Form(
                    key: _formKey,
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
                              ? 'Update Your Details'
                              : 'Business Details',
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
                          widget.isEditMode
                              ? 'Update your business location, customer links and payment information.'
                              : 'Add your location and links customers may need.',
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

                        _buildProgressIndicator(
                          context,
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        // ==================================================
                        // LOCATION
                        // ==================================================

                        _buildSectionTitle(
                          context,
                          'Location',
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        TextFormField(
                          controller:
                          _addressController,
                          maxLines: 2,
                          textInputAction:
                          TextInputAction
                              .next,
                          textCapitalization:
                          TextCapitalization
                              .sentences,
                          decoration:
                          const InputDecoration(
                            labelText:
                            'Address',
                            hintText:
                            'Street, building or landmark',
                            alignLabelWithHint:
                            true,
                            prefixIcon:
                            Icon(
                              Icons
                                  .location_on_outlined,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        // CITY + STATE
                        LayoutBuilder(
                          builder: (
                              context,
                              rowConstraints,
                              ) {
                            if (rowConstraints
                                .maxWidth <
                                500) {
                              return Column(
                                children: [
                                  _cityField(),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  _stateField(),
                                ],
                              );
                            }

                            return Row(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Expanded(
                                  child:
                                  _cityField(),
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                  child:
                                  _stateField(),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        // COUNTRY + PINCODE
                        LayoutBuilder(
                          builder: (
                              context,
                              rowConstraints,
                              ) {
                            if (rowConstraints
                                .maxWidth <
                                500) {
                              return Column(
                                children: [
                                  _countryField(),
                                  const SizedBox(
                                    height: 16,
                                  ),
                                  _pincodeField(),
                                ],
                              );
                            }

                            return Row(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Expanded(
                                  child:
                                  _countryField(),
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                  child:
                                  _pincodeField(),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(
                          height: 30,
                        ),

                        // ==================================================
                        // ONLINE PRESENCE
                        // ==================================================

                        _buildSectionTitle(
                          context,
                          'Online Presence',
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        TextFormField(
                          controller:
                          _googleReviewController,
                          keyboardType:
                          TextInputType.url,
                          textInputAction:
                          TextInputAction.next,
                          decoration:
                          const InputDecoration(
                            labelText:
                            'Google Review Link',
                            hintText:
                            'https://g.page/...',
                            prefixIcon:
                            Icon(
                              Icons
                                  .reviews_outlined,
                            ),
                            helperText:
                            'Optional — add your Google review link so customers can review your business.',
                          ),
                          validator: (value) {
                            final reviewUrl =
                                value?.trim() ?? '';

                            if (reviewUrl.isEmpty) {
                              return null;
                            }

                            final uri =
                            Uri.tryParse(reviewUrl);

                            if (uri == null ||
                                (uri.scheme != 'http' &&
                                    uri.scheme != 'https') ||
                                uri.host.isEmpty) {
                              return 'Enter a valid Google Review URL';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        TextFormField(
                          controller:
                          _descriptionController,
                          maxLines: 4,
                          maxLength: 1000,
                          textCapitalization:
                          TextCapitalization
                              .sentences,
                          decoration:
                          const InputDecoration(
                            labelText:
                            'Business description',
                            hintText:
                            'Tell customers a little about your business...',
                            prefixIcon:
                            Icon(
                              Icons
                                  .description_outlined,
                            ),
                            alignLabelWithHint:
                            true,
                          ),
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        _buildBusinessSummary(
                          context,
                        ),

                        const SizedBox(
                          height: 30,
                        ),

                        // ==================================================
                        // PAYMENTS
                        // ==================================================

                        _buildSectionTitle(
                          context,
                          'Payments',
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        TextFormField(
                          controller:
                          _upiController,
                          keyboardType:
                          TextInputType
                              .emailAddress,
                          textInputAction:
                          TextInputAction.done,
                          decoration:
                          const InputDecoration(
                            labelText:
                            'UPI ID',
                            hintText:
                            'business@upi',
                            prefixIcon:
                            Icon(
                              Icons
                                  .account_balance_wallet_outlined,
                            ),
                            helperText:
                            'Optional — you can add this later.',
                          ),
                          validator:
                              (value) {
                            final upi =
                                value
                                    ?.trim() ??
                                    '';

                            if (upi.isEmpty) {
                              return null;
                            }

                            if (!upi.contains(
                              '@',
                            )) {
                              return 'Enter a valid UPI ID';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        // ==================================================
                        // CONTINUE
                        // ==================================================

                        SizedBox(
                          width:
                          double.infinity,
                          height: 52,
                          child:
                          FilledButton.icon(
                            onPressed:
                            _continue,
                            icon:
                            const Icon(
                              Icons
                                  .arrow_forward_rounded,
                            ),
                            label:
                            const Text(
                              'Continue',
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
                            onPressed: () {
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
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
      BuildContext context,
      String title,
      ) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(
        fontWeight:
        FontWeight.w700,
      ),
    );
  }

  // ============================================================
  // CITY
  // ============================================================

  Widget _cityField() {
    return TextFormField(
      controller:
      _cityController,
      textInputAction:
      TextInputAction.next,
      textCapitalization:
      TextCapitalization.words,
      decoration:
      const InputDecoration(
        labelText: 'City',
        prefixIcon:
        Icon(
          Icons
              .location_city_outlined,
        ),
      ),
    );
  }

  // ============================================================
  // STATE
  // ============================================================

  Widget _stateField() {
    return TextFormField(
      controller:
      _stateController,
      textInputAction:
      TextInputAction.next,
      textCapitalization:
      TextCapitalization.words,
      decoration:
      const InputDecoration(
        labelText: 'State',
        prefixIcon:
        Icon(
          Icons.map_outlined,
        ),
      ),
    );
  }

  // ============================================================
  // COUNTRY
  // ============================================================

  Widget _countryField() {
    return TextFormField(
      controller:
      _countryController,
      textInputAction:
      TextInputAction.next,
      textCapitalization:
      TextCapitalization.words,
      decoration:
      const InputDecoration(
        labelText: 'Country',
        prefixIcon:
        Icon(
          Icons.public_outlined,
        ),
      ),
    );
  }

  // ============================================================
  // PINCODE
  // ============================================================

  Widget _pincodeField() {
    return TextFormField(
      controller:
      _pincodeController,
      keyboardType:
      TextInputType.number,
      maxLength: 6,
      textInputAction:
      TextInputAction.next,
      decoration:
      const InputDecoration(
        labelText: 'Pincode',
        counterText: '',
        prefixIcon:
        Icon(
          Icons.pin_drop_outlined,
        ),
      ),
      validator: (value) {
        final pincode =
            value?.trim() ?? '';

        if (pincode.isEmpty) {
          return null;
        }

        if (!RegExp(
          r'^\d{6}$',
        ).hasMatch(pincode)) {
          return 'Enter a valid 6-digit pincode';
        }

        return null;
      },
    );
  }

  // ============================================================
  // PROGRESS INDICATOR
  // ============================================================

  Widget _buildProgressIndicator(
      BuildContext context,
      ) {
    final colorScheme =
        Theme.of(context)
            .colorScheme;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 6,
            decoration:
            BoxDecoration(
              color:
              colorScheme.primary,
              borderRadius:
              BorderRadius.circular(
                10,
              ),
            ),
          ),
        ),

        const SizedBox(
          width: 8,
        ),

        Expanded(
          child: Container(
            height: 6,
            decoration:
            BoxDecoration(
              color:
              colorScheme.primary,
              borderRadius:
              BorderRadius.circular(
                10,
              ),
            ),
          ),
        ),

        const SizedBox(
          width: 8,
        ),

        Expanded(
          child: Container(
            height: 6,
            decoration:
            BoxDecoration(
              color: colorScheme
                  .surfaceContainerHighest,
              borderRadius:
              BorderRadius.circular(
                10,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUSINESS SUMMARY
  // ============================================================

  Widget _buildBusinessSummary(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(16),
      decoration:
      BoxDecoration(
        color: theme
            .colorScheme
            .surfaceContainerLow,
        borderRadius:
        BorderRadius.circular(
          16,
        ),
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
            style: theme
                .textTheme
                .titleMedium
                ?.copyWith(
              fontWeight:
              FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          _summaryRow(
            context,
            Icons.storefront_outlined,
            widget.businessName,
          ),

          const SizedBox(
            height: 8,
          ),

          _summaryRow(
            context,
            Icons.category_outlined,
            widget
                .businessType
                .displayName,
          ),

          const SizedBox(
            height: 8,
          ),

          _summaryRow(
            context,
            Icons.phone_outlined,
            widget.phone,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
      BuildContext context,
      IconData icon,
      String value,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment
          .start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context)
              .colorScheme
              .onSurfaceVariant,
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child: Text(
            value,
            softWrap: true,
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
          ),
        ),
      ],
    );
  }
}
