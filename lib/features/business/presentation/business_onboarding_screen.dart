import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/business_request.dart';
import '../data/models/business_response.dart';
import '../presentation/providers/business_notifier.dart';

import 'business_details_screen.dart';

class BusinessOnboardingScreen
    extends ConsumerStatefulWidget {
  const BusinessOnboardingScreen({
    super.key,
    this.isEditMode = false,
  });

  final bool isEditMode;

  @override
  ConsumerState<BusinessOnboardingScreen>
  createState() =>
      _BusinessOnboardingScreenState();
}

class _BusinessOnboardingScreenState
    extends ConsumerState<
        BusinessOnboardingScreen> {
  final _formKey =
  GlobalKey<FormState>();

  final _businessNameController =
  TextEditingController();

  final _phoneController =
  TextEditingController();

  final _whatsappController =
  TextEditingController();

  final _emailController =
  TextEditingController();

  BusinessType? _businessType;

  bool _loadingBusiness = false;
  bool _hasLoadedBusiness = false;

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
    _businessNameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD EXISTING BUSINESS
  // ============================================================

  Future<void> _loadExistingBusiness() async {
    if (_hasLoadedBusiness) {
      return;
    }

    setState(() {
      _loadingBusiness = true;
    });

    final notifier =
    ref.read(
      businessNotifierProvider
          .notifier,
    );

    await notifier.loadMyBusiness();

    if (!mounted) {
      return;
    }

    final state =
    ref.read(
      businessNotifierProvider,
    );

    final business = state.business;

    if (business != null) {
      _populateForm(business);
    }

    setState(() {
      _loadingBusiness = false;
      _hasLoadedBusiness = true;
    });
  }

  void _populateForm(
      BusinessResponse business,
      ) {
    _businessNameController.text =
        business.businessName;

    _phoneController.text =
        business.phone;

    _whatsappController.text =
        business.whatsapp ?? '';

    _emailController.text =
        business.email ?? '';

    _businessType =
        _parseBusinessType(
          business.businessType,
        );
  }

  // ============================================================
  // CONTINUE
  // ============================================================

  void _continue() {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    if (_businessType == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please select your business type.',
          ),
        ),
      );

      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            BusinessDetailsScreen(
              businessName:
              _businessNameController
                  .text
                  .trim(),
              businessType:
              _businessType!,
              phone:
              _phoneController.text
                  .trim(),
              whatsapp:
              _whatsappController
                  .text
                  .trim(),
              email:
              _emailController.text
                  .trim(),
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
  Widget build(BuildContext context) {
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
              ? 'Edit Business'
              : 'Business Setup',
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

            final topSpacing =
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
                topSpacing,
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
                              ? 'Update Your Business'
                              : 'Welcome to ScanAura',
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
                              ? 'Update your business information.'
                              : 'Let’s set up your business so you can start creating your digital menu.',
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
                          height: 28,
                        ),

                        // ==================================================
                        // PROGRESS
                        // ==================================================

                        _buildProgressIndicator(
                          context,
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        // ==================================================
                        // SECTION TITLE
                        // ==================================================

                        Text(
                          'Business Information',
                          style: theme
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        // ==================================================
                        // BUSINESS NAME
                        // ==================================================

                        TextFormField(
                          controller:
                          _businessNameController,
                          textInputAction:
                          TextInputAction
                              .next,
                          textCapitalization:
                          TextCapitalization
                              .words,
                          decoration:
                          const InputDecoration(
                            labelText:
                            'Business name',
                            hintText:
                            'e.g. The Green Plate',
                            prefixIcon:
                            Icon(
                              Icons
                                  .storefront_outlined,
                            ),
                          ),
                          validator:
                              (value) {
                            if (value ==
                                null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return 'Business name is required';
                            }

                            if (value
                                .trim()
                                .length <
                                3) {
                              return 'Enter at least 3 characters';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        // ==================================================
                        // BUSINESS TYPE
                        // ==================================================

                        DropdownButtonFormField<
                            BusinessType>(
                          initialValue:
                          _businessType,
                          decoration:
                          const InputDecoration(
                            labelText:
                            'Business type',
                            prefixIcon:
                            Icon(
                              Icons
                                  .category_outlined,
                            ),
                          ),
                          isExpanded: true,
                          items:
                          BusinessType
                              .values
                              .map(
                                (type) {
                              return DropdownMenuItem<
                                  BusinessType>(
                                value: type,
                                child: Text(
                                  type.displayName,
                                  overflow:
                                  TextOverflow
                                      .ellipsis,
                                ),
                              );
                            },
                          ).toList(),
                          onChanged:
                              (value) {
                            setState(() {
                              _businessType =
                                  value;
                            });
                          },
                          validator:
                              (value) {
                            if (value ==
                                null) {
                              return 'Select your business type';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        // ==================================================
                        // PHONE
                        // ==================================================

                        TextFormField(
                          controller:
                          _phoneController,
                          keyboardType:
                          TextInputType
                              .phone,
                          textInputAction:
                          TextInputAction
                              .next,
                          maxLength: 10,
                          decoration:
                          const InputDecoration(
                            labelText:
                            'Phone number',
                            hintText:
                            '9876543210',
                            counterText: '',
                            prefixIcon:
                            Icon(
                              Icons
                                  .phone_outlined,
                            ),
                          ),
                          validator:
                              (value) {
                            final phone =
                                value
                                    ?.trim() ??
                                    '';

                            if (phone
                                .isEmpty) {
                              return 'Phone number is required';
                            }

                            if (phone.length !=
                                10) {
                              return 'Enter a valid 10-digit number';
                            }

                            if (!RegExp(
                              r'^[0-9]+$',
                            ).hasMatch(
                              phone,
                            )) {
                              return 'Enter only numbers';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        // ==================================================
                        // WHATSAPP
                        // ==================================================

                        TextFormField(
                          controller:
                          _whatsappController,
                          keyboardType:
                          TextInputType
                              .phone,
                          textInputAction:
                          TextInputAction
                              .next,
                          maxLength: 10,
                          decoration:
                          const InputDecoration(
                            labelText:
                            'WhatsApp number',
                            hintText:
                            'Optional',
                            counterText: '',
                            prefixIcon:
                            Icon(
                              Icons
                                  .chat_outlined,
                            ),
                          ),
                          validator:
                              (value) {
                            final whatsapp =
                                value
                                    ?.trim() ??
                                    '';

                            if (whatsapp
                                .isEmpty) {
                              return null;
                            }

                            if (whatsapp.length !=
                                10) {
                              return 'Enter a valid 10-digit number';
                            }

                            if (!RegExp(
                              r'^[0-9]+$',
                            ).hasMatch(
                              whatsapp,
                            )) {
                              return 'Enter only numbers';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 16,
                        ),

                        // ==================================================
                        // EMAIL
                        // ==================================================

                        TextFormField(
                          controller:
                          _emailController,
                          keyboardType:
                          TextInputType
                              .emailAddress,
                          textInputAction:
                          TextInputAction
                              .done,
                          autofillHints:
                          const [
                            AutofillHints.email,
                          ],
                          decoration:
                          const InputDecoration(
                            labelText:
                            'Business email',
                            hintText:
                            'Optional',
                            prefixIcon:
                            Icon(
                              Icons
                                  .email_outlined,
                            ),
                          ),
                          validator:
                              (value) {
                            final email =
                                value
                                    ?.trim() ??
                                    '';

                            if (email
                                .isEmpty) {
                              return null;
                            }

                            final valid =
                            RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(
                              email,
                            );

                            if (!valid) {
                              return 'Enter a valid email address';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        // ==================================================
                        // CONTINUE BUTTON
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

                        if (!widget.isEditMode)
                          Text(
                            'You can update these details later from Business.',
                            textAlign:
                            TextAlign.center,
                            style: theme
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                              color: theme
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),

                        const SizedBox(
                          height: 12,
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
          flex: 1,
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
          flex: 1,
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

        const SizedBox(
          width: 8,
        ),

        Expanded(
          flex: 1,
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
  // BUSINESS TYPE PARSER
  // ============================================================

  BusinessType? _parseBusinessType(
      String? value,
      ) {
    if (value == null ||
        value.trim().isEmpty) {
      return null;
    }

    final normalized =
    value.trim().toUpperCase();

    for (final type
    in BusinessType.values) {
      if (type.name.toUpperCase() ==
          normalized) {
        return type;
      }

      if (type.apiValue ==
          normalized) {
        return type;
      }
    }

    return null;
  }
}