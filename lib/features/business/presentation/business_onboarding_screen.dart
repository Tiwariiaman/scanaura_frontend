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
  ConsumerState<BusinessOnboardingScreen> createState() =>
      _BusinessOnboardingScreenState();
}

class _BusinessOnboardingScreenState
    extends ConsumerState<BusinessOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

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
      Future.microtask(_loadExistingBusiness);
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

  Future<void> _loadExistingBusiness() async {
    if (_hasLoadedBusiness) {
      return;
    }

    setState(() {
      _loadingBusiness = true;
    });

    final notifier =
    ref.read(
      businessNotifierProvider.notifier,
    );

    await notifier.loadMyBusiness();

    if (!mounted) {
      return;
    }

    final state =
    ref.read(businessNotifierProvider);

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
        _parseBusinessType(business.businessType);
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) {
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
        builder: (_) => BusinessDetailsScreen(
          businessName:
          _businessNameController.text.trim(),
          businessType: _businessType!,
          phone:
          _phoneController.text.trim(),
          whatsapp:
          _whatsappController.text.trim(),
          email:
          _emailController.text.trim(),
          isEditMode:
          widget.isEditMode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
            const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 620,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 24,
                    ),

                    Text(
                      widget.isEditMode
                          ? 'Update Your Business'
                          : 'Welcome to ScanAura',
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
                      height: 32,
                    ),

                    _buildProgressIndicator(
                      context,
                    ),

                    const SizedBox(
                      height: 32,
                    ),

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
                      height: 20,
                    ),

                    TextFormField(
                      controller:
                      _businessNameController,
                      textInputAction:
                      TextInputAction.next,
                      decoration:
                      const InputDecoration(
                        labelText:
                        'Business name',
                        hintText:
                        'e.g. The Green Plate',
                        prefixIcon: Icon(
                          Icons
                              .storefront_outlined,
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
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

                    DropdownButtonFormField<
                        BusinessType>(
                      initialValue:
                      _businessType,
                      decoration:
                      const InputDecoration(
                        labelText:
                        'Business type',
                        prefixIcon: Icon(
                          Icons
                              .category_outlined,
                        ),
                      ),
                      items: BusinessType
                          .values
                          .map(
                            (type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              type.displayName,
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

                    TextFormField(
                      controller:
                      _phoneController,
                      keyboardType:
                      TextInputType.phone,
                      decoration:
                      const InputDecoration(
                        labelText:
                        'Phone number',
                        hintText:
                        '9876543210',
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value
                                .trim()
                                .isEmpty) {
                          return 'Phone number is required';
                        }

                        if (value
                            .trim()
                            .length !=
                            10) {
                          return 'Enter a valid 10-digit number';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    TextFormField(
                      controller:
                      _whatsappController,
                      keyboardType:
                      TextInputType.phone,
                      decoration:
                      const InputDecoration(
                        labelText:
                        'WhatsApp number',
                        hintText:
                        'Optional',
                        prefixIcon: Icon(
                          Icons.chat_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    TextFormField(
                      controller:
                      _emailController,
                      keyboardType:
                      TextInputType
                          .emailAddress,
                      decoration:
                      const InputDecoration(
                        labelText:
                        'Business email',
                        hintText:
                        'Optional',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 32,
                    ),

                    SizedBox(
                      width:
                      double.infinity,
                      height: 52,
                      child:
                      FilledButton.icon(
                        onPressed:
                        _continue,
                        icon: const Icon(
                          Icons
                              .arrow_forward_rounded,
                        ),
                        label: Text(
                          widget.isEditMode
                              ? 'Continue'
                              : 'Continue',
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
      ),
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

        const SizedBox(width: 8),

        Expanded(
          child: Container(
            height: 6,
            decoration:
            BoxDecoration(
              color:
              colorScheme
                  .surfaceContainerHighest,
              borderRadius:
              BorderRadius.circular(
                10,
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: Container(
            height: 6,
            decoration:
            BoxDecoration(
              color:
              colorScheme
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
  BusinessType? _parseBusinessType(
      String? value,
      ) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final normalized =
    value.trim().toUpperCase();

    for (final type in BusinessType.values) {
      if (type.name.toUpperCase() ==
          normalized) {
        return type;
      }
    }

    return null;
  }
}