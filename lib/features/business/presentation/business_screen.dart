import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scanaura_frontend/features/business/presentation/providers/business_notifier.dart';
import 'package:scanaura_frontend/features/business/presentation/providers/business_state.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/utils/image_compression_helper.dart';
import '../../gallery/presentation/widgets/gallery_manager.dart';
import '../data/models/business_request.dart';


class BusinessScreen extends ConsumerStatefulWidget {
  const BusinessScreen({super.key});

  @override
  ConsumerState<BusinessScreen> createState() =>
      _BusinessScreenState();
}

class _BusinessScreenState extends ConsumerState<BusinessScreen> {
  // ============================================================
  // LOADING STATES
  // ============================================================

  bool _googleReviewUpdating = false;
  bool _paymentUpdating = false;

  bool _instagramUpdating = false;
  bool _facebookUpdating = false;
  bool _youtubeUpdating = false;

  bool _callUpdating = false;
  bool _whatsappUpdating = false;
  bool _mapsUpdating = false;
  bool _galleryUpdating = false;

  bool _brandColorSaving = false;
  bool _logoUploading = false;

  // ============================================================
  // EXPANSION STATES
  // ============================================================

  bool _showContactDetails = false;
  bool _showMapsDetails = false;
  bool _showSocialDetails = false;
  bool _showBusinessInfo = false;

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _instagramController =
  TextEditingController();

  final TextEditingController _facebookController =
  TextEditingController();

  final TextEditingController _youtubeController =
  TextEditingController();

  final TextEditingController _brandColorController =
  TextEditingController();

  final TextEditingController _whatsappController =
  TextEditingController();

  final TextEditingController _googleMapsController =
  TextEditingController();

  // ============================================================
  // BRAND COLOR PRESETS
  // ============================================================

  static const List<String> _brandColorPresets = [
    '#2563EB',
    '#7C3AED',
    '#DB2777',
    '#DC2626',
    '#EA580C',
    '#D97706',
    '#16A34A',
    '#059669',
    '#0891B2',
    '#0F766E',
    '#4F46E5',
    '#111827',
  ];

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBusiness();
    });
  }

  @override
  void dispose() {
    _instagramController.dispose();
    _facebookController.dispose();
    _youtubeController.dispose();
    _brandColorController.dispose();
    _whatsappController.dispose();
    _googleMapsController.dispose();

    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  // ============================================================
  // LOAD BUSINESS
  // ============================================================

  Future<void> _checkBusiness() async {
    final notifier =
    ref.read(businessNotifierProvider.notifier);

    await notifier.loadMyBusiness();

    if (!mounted) return;

    final state = ref.read(businessNotifierProvider);

    final business = state.business;

    if (business != null) {
      _syncBusinessControllers(business);
      return;
    }

    if (state.status == BusinessStatus.error &&
        state.errorMessage == 'Business not found.') {
      context.go('/business-onboarding');
      return;
    }

    setState(() {});
  }

  Future<void> _refreshBusiness() async {
    final notifier =
    ref.read(businessNotifierProvider.notifier);

    await notifier.loadMyBusiness();

    if (!mounted) return;

    final business =
        ref.read(businessNotifierProvider).business;

    if (business != null) {
      _syncBusinessControllers(business);
    }
  }

  // ============================================================
  // BUSINESS TYPE
  // ============================================================

  BusinessType _parseBusinessType(dynamic value) {
    if (value is BusinessType) {
      return value;
    }

    final raw = value?.toString() ?? '';

    final name = raw.contains('.')
        ? raw.split('.').last
        : raw;

    return BusinessType.values.firstWhere(
          (type) =>
      type.apiValue.toUpperCase() ==
          name.toUpperCase(),
      orElse: () => BusinessType.other,
    );
  }

  String _businessTypeName(dynamic type) {
    if (type == null) {
      return 'Business';
    }

    if (type is BusinessType) {
      return type.displayName;
    }

    final value = type.toString();

    return value
        .replaceFirst('BusinessType.', '')
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
          ? word
          : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
    )
        .join(' ');
  }

  // ============================================================
  // CONTROLLERS
  // ============================================================

  void _syncBusinessControllers(dynamic business) {
    _setController(
      _instagramController,
      business.instagramUrl ?? '',
    );

    _setController(
      _facebookController,
      business.facebookUrl ?? '',
    );

    _setController(
      _youtubeController,
      business.youtubeUrl ?? '',
    );

    _setController(
      _brandColorController,
      business.brandColor ?? '',
    );

    _setController(
      _whatsappController,
      business.whatsapp ?? '',
    );

    _setController(
      _googleMapsController,
      business.googleMapsUrl ?? '',
    );
  }

  void _setController(
      TextEditingController controller,
      String value,
      ) {
    if (controller.text != value) {
      controller.text = value;
    }
  }

  // ============================================================
  // CURRENT BUSINESS
  // ============================================================

  dynamic _currentBusiness() {
    return ref.read(
      businessNotifierProvider,
    ).business;
  }

  // ============================================================
  // COMMON BUSINESS REQUEST
  // ============================================================

  BusinessRequest _buildBusinessRequest(
      dynamic business, {
        String? instagramUrl,
        bool? instagramEnabled,
        String? facebookUrl,
        bool? facebookEnabled,
        String? youtubeUrl,
        bool? youtubeEnabled,
        String? brandColor,
        bool? callEnabled,
        bool? whatsappEnabled,
        bool? mapsEnabled,
        bool? galleryEnabled,
        String? whatsapp,
        String? googleMapsUrl,
        String? logoUrl,
        String? logoPublicId,
      }) {
    return BusinessRequest(
      businessName: business.businessName,

      businessType:
      _parseBusinessType(
        business.businessType,
      ),

      phone: business.phone,

      logoUrl:
      logoUrl ?? business.logoUrl,

      logoPublicId:
      logoPublicId ?? business.logoPublicId,

      whatsapp:
      whatsapp ?? business.whatsapp,

      email: business.email,

      address: business.address,
      city: business.city,
      state: business.state,
      country: business.country,
      pincode: business.pincode,

      website: business.website,
      description: business.description,
      upiId: business.upiId,

      googleReviewUrl:
      business.googleReviewUrl,

      googleReviewEnabled:
      business.googleReviewEnabled,

      paymentEnabled:
      business.paymentEnabled,

      instagramUrl:
      instagramUrl ??
          business.instagramUrl,

      instagramEnabled:
      instagramEnabled ??
          business.instagramEnabled,

      facebookUrl:
      facebookUrl ??
          business.facebookUrl,

      facebookEnabled:
      facebookEnabled ??
          business.facebookEnabled,

      youtubeUrl:
      youtubeUrl ??
          business.youtubeUrl,

      youtubeEnabled:
      youtubeEnabled ??
          business.youtubeEnabled,

      brandColor:
      brandColor ??
          business.brandColor,

      googleMapsUrl:
      googleMapsUrl ??
          business.googleMapsUrl,

      callEnabled:
      callEnabled ??
          business.callEnabled,

      whatsappEnabled:
      whatsappEnabled ??
          business.whatsappEnabled,

      mapsEnabled:
      mapsEnabled ??
          business.mapsEnabled,

      galleryEnabled:
      galleryEnabled ??
          business.galleryEnabled,
    );
  }

  // ============================================================
  // LOGO UPLOAD
  // ============================================================

  Future<void> _pickAndUploadLogo() async {
    if (_logoUploading) return;

    final business = _currentBusiness();

    if (business == null) return;

    try {
      final result =
      await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
        allowMultiple: false,
      );

      if (result == null ||
          result.files.isEmpty) {
        return;
      }

      final file = result.files.first;

      if (file.bytes == null ||
          file.bytes!.isEmpty) {
        _showMessage(
          'Unable to read selected image.',
        );
        return;
      }

      setState(() {
        _logoUploading = true;
      });

      final compressed =
      await ImageCompressionHelper
          .compressLogo(
        file.bytes!,
      );

      final uploadService =
      ref.read(
        imageUploadServiceProvider,
      );

      final uploaded =
      await uploadService.uploadBusinessLogo(
        compressed,
        file.name,
      );

      final request =
      _buildBusinessRequest(
        business,
        logoUrl: uploaded.imageUrl,
        logoPublicId: uploaded.publicId,
      );

      await ref
          .read(
        businessNotifierProvider
            .notifier,
      )
          .updateBusiness(request);

      if (!mounted) return;

      final state =
      ref.read(
        businessNotifierProvider,
      );

      if (state.status ==
          BusinessStatus.success) {
        _showMessage(
          'Business logo updated.',
        );
      } else {
        _showMessage(
          state.errorMessage ??
              'Unable to update logo.',
        );
      }
    } catch (e) {
      if (mounted) {
        _showMessage(
          _cleanError(e),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _logoUploading = false;
        });
      }
    }
  }

  // ============================================================
  // BRAND COLOR
  // ============================================================

  Future<void> _saveBrandColor() async {
    if (_brandColorSaving) return;

    final business = _currentBusiness();

    if (business == null) return;

    final value =
    _normalizeHexColor(
      _brandColorController.text,
    );

    if (value == null) {
      _showMessage(
        'Enter a valid HEX color, for example #2563EB.',
      );
      return;
    }

    setState(() {
      _brandColorSaving = true;
    });

    try {
      final request =
      _buildBusinessRequest(
        business,
        brandColor: value,
      );

      await ref
          .read(
        businessNotifierProvider
            .notifier,
      )
          .updateBusiness(request);

      if (!mounted) return;

      final state =
      ref.read(
        businessNotifierProvider,
      );

      if (state.status ==
          BusinessStatus.success) {
        _showMessage(
          'Brand color updated.',
        );
      } else {
        _showMessage(
          state.errorMessage ??
              'Failed to update brand color.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _brandColorSaving = false;
        });
      }
    }
  }

  String? _normalizeHexColor(String value) {
    var color = value.trim();

    if (color.isEmpty) {
      return null;
    }

    if (!color.startsWith('#')) {
      color = '#$color';
    }

    final valid =
    RegExp(r'^#[0-9A-Fa-f]{6}$')
        .hasMatch(color);

    if (!valid) {
      return null;
    }

    return color.toUpperCase();
  }

  Color _colorFromHex(
      String? value, {
        Color fallback = Colors.blue,
      }) {
    final normalized =
    _normalizeHexColor(
      value ?? '',
    );

    if (normalized == null) {
      return fallback;
    }

    final hex =
    normalized.substring(1);

    return Color(
      int.parse(
        'FF$hex',
        radix: 16,
      ),
    );
  }

  // ============================================================
  // GOOGLE REVIEW
  // ============================================================

  Future<void> _setGoogleReviewEnabled(
      bool value,
      ) async {
    if (_googleReviewUpdating) return;

    final business = _currentBusiness();

    if (business == null) return;

    if (value &&
        (business.googleReviewUrl == null ||
            business.googleReviewUrl
                .toString()
                .trim()
                .isEmpty)) {
      _showMessage(
        'Add your Google Review link first.',
      );
      return;
    }

    setState(() {
      _googleReviewUpdating = true;
    });

    try {
      final request =
      _buildBusinessRequest(
        business,
      );

      final updatedRequest =
      BusinessRequest(
        businessName:
        request.businessName,
        businessType:
        request.businessType,
        phone: request.phone,
        logoUrl: request.logoUrl,
        logoPublicId:
        request.logoPublicId,
        whatsapp:
        request.whatsapp,
        email: request.email,
        address:
        request.address,
        city: request.city,
        state: request.state,
        country:
        request.country,
        pincode:
        request.pincode,
        website:
        request.website,
        description:
        request.description,
        upiId:
        request.upiId,
        googleReviewUrl:
        request.googleReviewUrl,
        googleReviewEnabled:
        value,
        paymentEnabled:
        request.paymentEnabled,
        instagramUrl:
        request.instagramUrl,
        instagramEnabled:
        request.instagramEnabled,
        facebookUrl:
        request.facebookUrl,
        facebookEnabled:
        request.facebookEnabled,
        youtubeUrl:
        request.youtubeUrl,
        youtubeEnabled:
        request.youtubeEnabled,
        brandColor:
        request.brandColor,
        googleMapsUrl:
        request.googleMapsUrl,
        callEnabled:
        request.callEnabled,
        whatsappEnabled:
        request.whatsappEnabled,
        mapsEnabled:
        request.mapsEnabled,
        galleryEnabled:
        request.galleryEnabled,
      );

      await ref
          .read(
        businessNotifierProvider
            .notifier,
      )
          .updateBusiness(
        updatedRequest,
      );
    } finally {
      if (mounted) {
        setState(() {
          _googleReviewUpdating = false;
        });
      }
    }
  }

  // ============================================================
  // PAYMENT
  // ============================================================

  Future<void> _setPaymentEnabled(
      bool value,
      ) async {
    if (_paymentUpdating) return;

    final business = _currentBusiness();

    if (business == null) return;

    setState(() {
      _paymentUpdating = true;
    });

    try {
      final request =
      _buildBusinessRequest(
        business,
      );

      final updatedRequest =
      BusinessRequest(
        businessName:
        request.businessName,
        businessType:
        request.businessType,
        phone: request.phone,
        logoUrl: request.logoUrl,
        logoPublicId:
        request.logoPublicId,
        whatsapp:
        request.whatsapp,
        email:
        request.email,
        address:
        request.address,
        city:
        request.city,
        state:
        request.state,
        country:
        request.country,
        pincode:
        request.pincode,
        website:
        request.website,
        description:
        request.description,
        upiId:
        request.upiId,
        googleReviewUrl:
        request.googleReviewUrl,
        googleReviewEnabled:
        request.googleReviewEnabled,
        paymentEnabled:
        value,
        instagramUrl:
        request.instagramUrl,
        instagramEnabled:
        request.instagramEnabled,
        facebookUrl:
        request.facebookUrl,
        facebookEnabled:
        request.facebookEnabled,
        youtubeUrl:
        request.youtubeUrl,
        youtubeEnabled:
        request.youtubeEnabled,
        brandColor:
        request.brandColor,
        googleMapsUrl:
        request.googleMapsUrl,
        callEnabled:
        request.callEnabled,
        whatsappEnabled:
        request.whatsappEnabled,
        mapsEnabled:
        request.mapsEnabled,
        galleryEnabled:
        request.galleryEnabled,
      );

      await ref
          .read(
        businessNotifierProvider
            .notifier,
      )
          .updateBusiness(
        updatedRequest,
      );
    } finally {
      if (mounted) {
        setState(() {
          _paymentUpdating = false;
        });
      }
    }
  }

  // ============================================================
  // SOCIAL
  // ============================================================

  Future<void> _setInstagramEnabled(
      bool value,
      ) async {
    await _updateSocialFeature(
      type: 'instagram',
      value: value,
    );
  }

  Future<void> _setFacebookEnabled(
      bool value,
      ) async {
    await _updateSocialFeature(
      type: 'facebook',
      value: value,
    );
  }

  Future<void> _setYoutubeEnabled(
      bool value,
      ) async {
    await _updateSocialFeature(
      type: 'youtube',
      value: value,
    );
  }

  Future<void> _updateSocialFeature({
    required String type,
    required bool value,
  }) async {
    if (type == 'instagram' &&
        _instagramUpdating) {
      return;
    }

    if (type == 'facebook' &&
        _facebookUpdating) {
      return;
    }

    if (type == 'youtube' &&
        _youtubeUpdating) {
      return;
    }

    final business = _currentBusiness();

    if (business == null) return;

    final url =
    type == 'instagram'
        ? _instagramController.text.trim()
        : type == 'facebook'
        ? _facebookController.text.trim()
        : _youtubeController.text.trim();

    if (value && url.isEmpty) {
      _showMessage(
        'Add your ${_socialName(type)} link first.',
      );
      return;
    }

    setState(() {
      if (type == 'instagram') {
        _instagramUpdating = true;
      } else if (type == 'facebook') {
        _facebookUpdating = true;
      } else {
        _youtubeUpdating = true;
      }
    });

    try {
      final request =
      _buildBusinessRequest(
        business,
        instagramUrl:
        type == 'instagram'
            ? url
            : business.instagramUrl,
        instagramEnabled:
        type == 'instagram'
            ? value
            : business.instagramEnabled,
        facebookUrl:
        type == 'facebook'
            ? url
            : business.facebookUrl,
        facebookEnabled:
        type == 'facebook'
            ? value
            : business.facebookEnabled,
        youtubeUrl:
        type == 'youtube'
            ? url
            : business.youtubeUrl,
        youtubeEnabled:
        type == 'youtube'
            ? value
            : business.youtubeEnabled,
      );

      await ref
          .read(
        businessNotifierProvider
            .notifier,
      )
          .updateBusiness(request);
    } finally {
      if (mounted) {
        setState(() {
          if (type == 'instagram') {
            _instagramUpdating = false;
          } else if (type == 'facebook') {
            _facebookUpdating = false;
          } else {
            _youtubeUpdating = false;
          }
        });
      }
    }
  }

  Future<void> _saveSocialLink(
      String type,
      ) async {
    final business = _currentBusiness();

    if (business == null) return;

    final request =
    _buildBusinessRequest(
      business,
      instagramUrl:
      _instagramController.text.trim(),
      facebookUrl:
      _facebookController.text.trim(),
      youtubeUrl:
      _youtubeController.text.trim(),
    );

    await ref
        .read(
      businessNotifierProvider
          .notifier,
    )
        .updateBusiness(request);

    if (!mounted) return;

    final state =
    ref.read(
      businessNotifierProvider,
    );

    if (state.status ==
        BusinessStatus.success) {
      _showMessage(
        '${_socialName(type)} link saved.',
      );
    } else {
      _showMessage(
        state.errorMessage ??
            'Failed to save social link.',
      );
    }
  }

  String _socialName(String type) {
    switch (type) {
      case 'instagram':
        return 'Instagram';
      case 'facebook':
        return 'Facebook';
      case 'youtube':
        return 'YouTube';
      default:
        return 'Social';
    }
  }

  // ============================================================
  // CONTACT FEATURES
  // ============================================================

  Future<void> _setCallEnabled(
      bool value,
      ) async {
    final business = _currentBusiness();

    if (business == null ||
        _callUpdating) {
      return;
    }

    final phone =
        business.phone?.toString().trim() ?? '';

    if (value && phone.isEmpty) {
      _showMessage(
        'Add a phone number first.',
      );
      return;
    }

    setState(() {
      _callUpdating = true;
    });

    try {
      await _updateBusinessContactFeature(
        business,
        callEnabled: value,
      );
    } finally {
      if (mounted) {
        setState(() {
          _callUpdating = false;
        });
      }
    }
  }

  Future<void> _setWhatsappEnabled(
      bool value,
      ) async {
    final business = _currentBusiness();

    if (business == null ||
        _whatsappUpdating) {
      return;
    }

    final whatsapp =
    _whatsappController.text.trim();

    if (value && whatsapp.isEmpty) {
      _showMessage(
        'Add a WhatsApp number first.',
      );
      return;
    }

    if (value &&
        !_isValidIndianPhone(
          whatsapp,
        )) {
      _showMessage(
        'Enter a valid 10-digit WhatsApp number.',
      );
      return;
    }

    setState(() {
      _whatsappUpdating = true;
    });

    try {
      await _updateBusinessContactFeature(
        business,
        whatsapp: whatsapp,
        whatsappEnabled: value,
      );
    } finally {
      if (mounted) {
        setState(() {
          _whatsappUpdating = false;
        });
      }
    }
  }

  Future<void> _setMapsEnabled(
      bool value,
      ) async {
    final business = _currentBusiness();

    if (business == null ||
        _mapsUpdating) {
      return;
    }

    final maps =
    _googleMapsController.text.trim();

    if (value && maps.isEmpty) {
      _showMessage(
        'Add a Google Maps link first.',
      );
      return;
    }

    if (value &&
        !_isValidUrl(maps)) {
      _showMessage(
        'Enter a valid Google Maps URL.',
      );
      return;
    }

    setState(() {
      _mapsUpdating = true;
    });

    try {
      await _updateBusinessContactFeature(
        business,
        googleMapsUrl: maps,
        mapsEnabled: value,
      );
    } finally {
      if (mounted) {
        setState(() {
          _mapsUpdating = false;
        });
      }
    }
  }

  Future<void> _setGalleryEnabled(
      bool value,
      ) async {
    final business = _currentBusiness();

    if (business == null ||
        _galleryUpdating) {
      return;
    }

    setState(() {
      _galleryUpdating = true;
    });

    try {
      await _updateBusinessContactFeature(
        business,
        galleryEnabled: value,
      );
    } finally {
      if (mounted) {
        setState(() {
          _galleryUpdating = false;
        });
      }
    }
  }

  Future<void> _updateBusinessContactFeature(
      dynamic business, {
        String? whatsapp,
        String? googleMapsUrl,
        bool? callEnabled,
        bool? whatsappEnabled,
        bool? mapsEnabled,
        bool? galleryEnabled,
      }) async {
    final request =
    _buildBusinessRequest(
      business,
      whatsapp:
      whatsapp ?? business.whatsapp,
      googleMapsUrl:
      googleMapsUrl ??
          business.googleMapsUrl,
      callEnabled:
      callEnabled ??
          business.callEnabled,
      whatsappEnabled:
      whatsappEnabled ??
          business.whatsappEnabled,
      mapsEnabled:
      mapsEnabled ??
          business.mapsEnabled,
      galleryEnabled:
      galleryEnabled ??
          business.galleryEnabled,
    );

    await ref
        .read(
      businessNotifierProvider
          .notifier,
    )
        .updateBusiness(request);
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  bool _isValidIndianPhone(
      String value,
      ) {
    final digits =
    value.replaceAll(
      RegExp(r'\D'),
      '',
    );

    if (digits.length == 10) {
      return true;
    }

    return digits.length == 12 &&
        digits.startsWith('91');
  }

  bool _isValidUrl(
      String value,
      ) {
    final uri = Uri.tryParse(value);

    if (uri == null) {
      return false;
    }

    return uri.hasScheme &&
        (uri.scheme == 'http' ||
            uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final state =
    ref.watch(
      businessNotifierProvider,
    );

    final business = state.business;

    return Scaffold(
      backgroundColor:
      Theme.of(context)
          .colorScheme
          .surfaceContainerLowest,
      body: business == null
          ? _buildLoadingOrEmpty(
        context,
        state,
      )
          : RefreshIndicator(
        onRefresh:
        _refreshBusiness,
        child: CustomScrollView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor:
              Theme.of(context)
                  .colorScheme
                  .surfaceContainerLowest,
              titleSpacing: 20,
              title:
              _buildTopBarTitle(
                context,
              ),
              actions: [
                IconButton(
                  tooltip:
                  'Refresh',
                  onPressed:
                  _refreshBusiness,
                  icon: const Icon(
                    Icons
                        .refresh_rounded,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
              ],
            ),
            SliverPadding(
              padding:
              const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                48,
              ),
              sliver:
              SliverList(
                delegate:
                SliverChildListDelegate(
                  [
                    _buildBusinessHero(
                      context,
                      business,
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    _buildQuickSettings(
                      context,
                      business,
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    if (business.galleryEnabled ==
                        true)
                      GalleryManager(
                        businessId:
                        business.id
                            .toString(),
                      ),

                    if (business.galleryEnabled ==
                        true)
                      const SizedBox(
                        height: 18,
                      ),

                    _buildPublicPageSection(
                      context,
                      business,
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    _buildBusinessInformation(
                      context,
                      business,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBarTitle(
      BuildContext context,
      ) {
    final theme =
    Theme.of(context);

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'Business',
          style: theme
              .textTheme
              .titleLarge
              ?.copyWith(
            fontWeight:
            FontWeight.w800,
            letterSpacing: -.4,
          ),
        ),
        Text(
          'Your digital business identity',
          style: theme
              .textTheme
              .bodySmall
              ?.copyWith(
            color:
            theme.colorScheme
                .onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildBusinessHero(
      BuildContext context,
      dynamic business,
      ) {
    final theme =
    Theme.of(context);

    final scheme =
        theme.colorScheme;

    final name =
    business.businessName
        ?.toString()
        .trim()
        .isNotEmpty ==
        true
        ? business.businessName
        .toString()
        : 'Your Business';

    final type =
    _businessTypeName(
      business.businessType,
    );

    final logoUrl =
        business.logoUrl
            ?.toString()
            .trim() ??
            '';

    final active =
        business.active == true;

    final brandColor =
    _colorFromHex(
      business.brandColor,
      fallback:
      scheme.primary,
    );

    return Container(
      padding:
      const EdgeInsets.all(22),
      decoration:
      BoxDecoration(
        gradient:
        LinearGradient(
          begin:
          Alignment.topLeft,
          end:
          Alignment.bottomRight,
          colors: [
            scheme.surface,
            Color.lerp(
              scheme.surface,
              brandColor,
              .035,
            ) ??
                scheme.surface,
          ],
        ),
        borderRadius:
        BorderRadius.circular(
          30,
        ),
        border: Border.all(
          color: scheme
              .outlineVariant
              .withOpacity(.45),
        ),
        boxShadow: [
          BoxShadow(
            color:
            brandColor.withOpacity(
              .07,
            ),
            blurRadius: 35,
            offset:
            const Offset(
              0,
              15,
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap:
            _logoUploading
                ? null
                : _pickAndUploadLogo,
            child: Stack(
              alignment:
              Alignment.bottomRight,
              children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration:
                  BoxDecoration(
                    color: scheme
                        .surfaceContainerHighest,
                    borderRadius:
                    BorderRadius.circular(
                      32,
                    ),
                    border: Border.all(
                      color: brandColor
                          .withOpacity(
                        .28,
                      ),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: brandColor
                            .withOpacity(
                          .10,
                        ),
                        blurRadius: 20,
                        offset:
                        const Offset(
                          0,
                          8,
                        ),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius:
                    BorderRadius.circular(
                      30,
                    ),
                    child: logoUrl
                        .isNotEmpty
                        ? Image.network(
                      logoUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (
                          _,
                          __,
                          ___,
                          ) {
                        return Icon(
                          Icons
                              .storefront_rounded,
                          size: 46,
                          color: scheme
                              .onSurfaceVariant,
                        );
                      },
                    )
                        : Icon(
                      Icons
                          .storefront_rounded,
                      size: 46,
                      color: scheme
                          .onSurfaceVariant,
                    ),
                  ),
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration:
                  BoxDecoration(
                    color: brandColor,
                    shape:
                    BoxShape.circle,
                    border: Border.all(
                      color:
                      scheme.surface,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: brandColor
                            .withOpacity(
                          .25,
                        ),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child:
                  _logoUploading
                      ? Padding(
                    padding:
                    const EdgeInsets.all(
                      9,
                    ),
                    child:
                    CircularProgressIndicator(
                      strokeWidth:
                      2,
                      color: scheme
                          .onPrimary,
                    ),
                  )
                      : Icon(
                    Icons
                        .edit_rounded,
                    size: 18,
                    color: scheme
                        .onPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          Text(
            name,
            textAlign:
            TextAlign.center,
            style: theme
                .textTheme
                .headlineSmall
                ?.copyWith(
              fontWeight:
              FontWeight.w800,
              letterSpacing: -.8,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Icon(
                Icons
                    .verified_outlined,
                size: 17,
                color:
                brandColor,
              ),
              const SizedBox(
                width: 6,
              ),
              Text(
                type,
                style: theme
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  color: scheme
                      .onSurfaceVariant,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 13,
          ),

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 7,
            ),
            decoration:
            BoxDecoration(
              color: active
                  ? Colors.green
                  .withOpacity(.10)
                  : scheme
                  .surfaceContainerHighest,
              borderRadius:
              BorderRadius.circular(
                30,
              ),
            ),
            child: Row(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration:
                  BoxDecoration(
                    color: active
                        ? Colors.green
                        : scheme
                        .onSurfaceVariant,
                    shape:
                    BoxShape.circle,
                  ),
                ),
                const SizedBox(
                  width: 7,
                ),
                Text(
                  active
                      ? 'Public profile active'
                      : 'Profile inactive',
                  style: theme
                      .textTheme
                      .labelLarge
                      ?.copyWith(
                    color: active
                        ? Colors.green
                        .shade700
                        : scheme
                        .onSurfaceVariant,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push(
                      '/business-onboarding?edit=true',
                    );
                  },
                  icon: const Icon(
                    Icons
                        .edit_rounded,
                    size: 19,
                  ),
                  label:
                  const Text(
                    'Edit Profile',
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    _showBrandColorSheet(
                      context,
                      business,
                    );
                  },
                  icon: const Icon(
                    Icons
                        .palette_outlined,
                    size: 19,
                  ),
                  label:
                  const Text(
                    'Appearance',
                  ),
                  style:
                  FilledButton.styleFrom(
                    backgroundColor:
                    brandColor,
                    foregroundColor:
                    _contrastColor(
                      brandColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK SETTINGS
  // ============================================================

  Widget _buildQuickSettings(
      BuildContext context,
      dynamic business,
      ) {
    return _buildModernCard(
      context,
      child: Column(
        children: [
          _buildSectionHeader(
            context,
            title:
            'Quick Settings',
            subtitle:
            'Choose how customers interact with your business.',
            icon:
            Icons.tune_rounded,
          ),

          const SizedBox(
            height: 14,
          ),

          _buildSettingRow(
            context,
            icon:
            Icons.phone_outlined,
            title: 'Call',
            subtitle:
            'Let customers call you directly',
            enabled:
            business.callEnabled ==
                true,
            loading:
            _callUpdating,
            onChanged:
            _setCallEnabled,
          ),

          _buildSettingDivider(),

          _buildSettingRow(
            context,
            icon:
            Icons
                .chat_bubble_outline_rounded,
            title: 'WhatsApp',
            subtitle:
            'Let customers contact you on WhatsApp',
            enabled:
            business.whatsappEnabled ==
                true,
            loading:
            _whatsappUpdating,
            onTap: () {
              setState(() {
                _showContactDetails =
                !_showContactDetails;
              });
            },
            onChanged:
            _setWhatsappEnabled,
          ),

          if (_showContactDetails)
            _buildInlineInput(
              context,
              controller:
              _whatsappController,
              label:
              'WhatsApp number',
              hint:
              '9876543210',
              keyboardType:
              TextInputType.phone,
              icon:
              Icons.phone_outlined,
              onSave: () async {
                final current =
                _currentBusiness();

                if (current == null) {
                  return;
                }

                final value =
                _whatsappController
                    .text
                    .trim();

                if (!_isValidIndianPhone(
                  value,
                )) {
                  _showMessage(
                    'Enter a valid 10-digit WhatsApp number.',
                  );
                  return;
                }

                await _updateBusinessContactFeature(
                  current,
                  whatsapp: value,
                );

                if (mounted) {
                  _showMessage(
                    'WhatsApp number saved.',
                  );
                }
              },
            ),

          _buildSettingDivider(),

          _buildSettingRow(
            context,
            icon:
            Icons
                .location_on_outlined,
            title:
            'Google Maps',
            subtitle:
            'Show directions on your public page',
            enabled:
            business.mapsEnabled ==
                true,
            loading:
            _mapsUpdating,
            onTap: () {
              setState(() {
                _showMapsDetails =
                !_showMapsDetails;
              });
            },
            onChanged:
            _setMapsEnabled,
          ),

          if (_showMapsDetails)
            _buildInlineInput(
              context,
              controller:
              _googleMapsController,
              label:
              'Google Maps URL',
              hint:
              'https://maps.google.com/...',
              keyboardType:
              TextInputType.url,
              icon:
              Icons.link_rounded,
              onSave: () async {
                final current =
                _currentBusiness();

                if (current == null) {
                  return;
                }

                final value =
                _googleMapsController
                    .text
                    .trim();

                if (!_isValidUrl(
                  value,
                )) {
                  _showMessage(
                    'Enter a valid Google Maps URL.',
                  );
                  return;
                }

                await _updateBusinessContactFeature(
                  current,
                  googleMapsUrl:
                  value,
                );

                if (mounted) {
                  _showMessage(
                    'Google Maps link saved.',
                  );
                }
              },
            ),

          _buildSettingDivider(),

          _buildSettingRow(
            context,
            icon:
            Icons
                .photo_library_outlined,
            title:
            'Gallery',
            subtitle:
            'Show your business images publicly',
            enabled:
            business.galleryEnabled ==
                true,
            loading:
            _galleryUpdating,
            onChanged:
            _setGalleryEnabled,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PUBLIC PAGE
  // ============================================================

  Widget _buildPublicPageSection(
      BuildContext context,
      dynamic business,
      ) {
    return _buildModernCard(
      context,
      child: Column(
        children: [
          _buildSectionHeader(
            context,
            title:
            'Public Page',
            subtitle:
            'Control the content customers see.',
            icon:
            Icons.public_rounded,
          ),

          const SizedBox(
            height: 14,
          ),

          _buildSettingRow(
            context,
            icon:
            Icons
                .rate_review_outlined,
            title:
            'Google Reviews',
            subtitle:
            'Show a review button to visitors',
            enabled:
            business.googleReviewEnabled ==
                true,
            loading:
            _googleReviewUpdating,
            onChanged:
            _setGoogleReviewEnabled,
          ),

          _buildSettingDivider(),

          _buildSettingRow(
            context,
            icon:
            Icons.share_outlined,
            title:
            'Social Media',
            subtitle:
            'Instagram, Facebook and YouTube',
            enabled:
            _hasEnabledSocial(
              business,
            ),
            onTap: () {
              setState(() {
                _showSocialDetails =
                !_showSocialDetails;
              });
            },
          ),

          if (_showSocialDetails)
            _buildSocialEditor(
              context,
              business,
            ),

          _buildSettingDivider(),

          _buildSettingRow(
            context,
            icon:
            Icons
                .palette_outlined,
            title:
            'Brand Appearance',
            subtitle:
            business.brandColor
                ?.toString()
                .trim()
                .isNotEmpty ==
                true
                ? 'Custom color • ${business.brandColor}'
                : 'Choose your public page color',
            enabled:
            business.brandColor !=
                null &&
                business.brandColor
                    .toString()
                    .trim()
                    .isNotEmpty,
            onTap: () {
              _showBrandColorSheet(
                context,
                business,
              );
            },
          ),

          _buildSettingDivider(),

          _buildSettingRow(
            context,
            icon:
            Icons
                .account_balance_wallet_outlined,
            title:
            'UPI Payments',
            subtitle:
            'Payment feature is coming soon',
            enabled:
            business.paymentEnabled ==
                true,
            loading:
            _paymentUpdating,
            disabled: true,
            onChanged:
            _setPaymentEnabled,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SOCIAL EDITOR
  // ============================================================

  Widget _buildSocialEditor(
      BuildContext context,
      dynamic business,
      ) {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        4,
        4,
        4,
        14,
      ),
      child: Column(
        children: [
          _buildSocialEditorRow(
            context,
            title:
            'Instagram',
            icon:
            Icons.camera_alt_outlined,
            controller:
            _instagramController,
            enabled:
            business.instagramEnabled ==
                true,
            loading:
            _instagramUpdating,
            onChanged:
            _setInstagramEnabled,
            onSave: () =>
                _saveSocialLink(
                  'instagram',
                ),
          ),

          const SizedBox(
            height: 10,
          ),

          _buildSocialEditorRow(
            context,
            title:
            'Facebook',
            icon:
            Icons.facebook_outlined,
            controller:
            _facebookController,
            enabled:
            business.facebookEnabled ==
                true,
            loading:
            _facebookUpdating,
            onChanged:
            _setFacebookEnabled,
            onSave: () =>
                _saveSocialLink(
                  'facebook',
                ),
          ),

          const SizedBox(
            height: 10,
          ),

          _buildSocialEditorRow(
            context,
            title:
            'YouTube',
            icon:
            Icons
                .ondemand_video_outlined,
            controller:
            _youtubeController,
            enabled:
            business.youtubeEnabled ==
                true,
            loading:
            _youtubeUpdating,
            onChanged:
            _setYoutubeEnabled,
            onSave: () =>
                _saveSocialLink(
                  'youtube',
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialEditorRow(
      BuildContext context, {
        required String title,
        required IconData icon,
        required TextEditingController
        controller,
        required bool enabled,
        required bool loading,
        required Future<void> Function(
            bool value,
            ) onChanged,
        required Future<void> Function()
        onSave,
      }) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    return Container(
      padding:
      const EdgeInsets.all(13),
      decoration:
      BoxDecoration(
        color: scheme
            .surfaceContainerLowest,
        borderRadius:
        BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color: scheme
              .outlineVariant
              .withOpacity(.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildSmallIconBox(
                context,
                icon,
              ),
              const SizedBox(
                width: 11,
              ),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),
              loading
                  ? const SizedBox(
                width: 22,
                height: 22,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : Switch.adaptive(
                value:
                enabled,
                onChanged:
                onChanged,
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          Row(
            children: [
              Expanded(
                child:
                TextField(
                  controller:
                  controller,
                  keyboardType:
                  TextInputType.url,
                  decoration:
                  InputDecoration(
                    hintText:
                    'Profile URL',
                    prefixIcon:
                    const Icon(
                      Icons.link_rounded,
                    ),
                    isDense:
                    true,
                    filled: true,
                    fillColor: scheme
                        .surface,
                    border:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius
                          .circular(
                        13,
                      ),
                      borderSide:
                      BorderSide(
                        color: scheme
                            .outlineVariant,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              SizedBox(
                height: 48,
                child:
                FilledButton(
                  onPressed:
                  loading
                      ? null
                      : onSave,
                  child:
                  const Text(
                    'Save',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUSINESS INFORMATION
  // ============================================================

  Widget _buildBusinessInformation(
      BuildContext context,
      dynamic business,
      ) {
    return _buildModernCard(
      context,
      child: Column(
        children: [
          _buildSectionHeader(
            context,
            title:
            'Business Information',
            subtitle:
            'Your saved business details.',
            icon:
            Icons.business_rounded,
          ),

          const SizedBox(
            height: 14,
          ),

          _buildSettingRow(
            context,
            icon:
            Icons
                .contact_phone_outlined,
            title:
            'Contact & Location',
            subtitle:
            _contactSummary(
              business,
            ),
            onTap: () {
              setState(() {
                _showBusinessInfo =
                !_showBusinessInfo;
              });
            },
          ),

          if (_showBusinessInfo)
            _buildInfoContent(
              context,
              business,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoContent(
      BuildContext context,
      dynamic business,
      ) {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        52,
        2,
        0,
        10,
      ),
      child: Column(
        children: [
          _buildCompactInfo(
            context,
            'Phone',
            business.phone,
            Icons.phone_outlined,
          ),
          _buildCompactInfo(
            context,
            'Email',
            business.email,
            Icons.email_outlined,
          ),
          _buildCompactInfo(
            context,
            'Address',
            business.address,
            Icons.home_outlined,
          ),
          _buildCompactInfo(
            context,
            'City',
            business.city,
            Icons.location_city_outlined,
          ),
          _buildCompactInfo(
            context,
            'State',
            business.state,
            Icons.map_outlined,
          ),
          _buildCompactInfo(
            context,
            'Country',
            business.country,
            Icons.public_outlined,
          ),
          _buildCompactInfo(
            context,
            'Pincode',
            business.pincode,
            Icons.pin_drop_outlined,
          ),
          _buildCompactInfo(
            context,
            'Website',
            business.website,
            Icons.language_outlined,
          ),
          _buildCompactInfo(
            context,
            'Description',
            business.description,
            Icons.description_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfo(
      BuildContext context,
      String label,
      dynamic value,
      IconData icon,
      ) {
    final text =
        value?.toString().trim() ?? '';

    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    final scheme =
        Theme.of(context)
            .colorScheme;

    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 12,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color:
            scheme.onSurfaceVariant,
          ),
          const SizedBox(
            width: 10,
          ),
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: Theme.of(
                context,
              )
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                color: scheme
                    .onSurfaceVariant,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              )
                  .textTheme
                  .bodySmall
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

  // ============================================================
  // BRAND COLOR SHEET
  // ============================================================

  Future<void> _showBrandColorSheet(
      BuildContext context,
      dynamic business,
      ) async {
    final controller =
    TextEditingController(
      text:
      business.brandColor
          ?.toString() ??
          '',
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor:
      Theme.of(context)
          .colorScheme
          .surface,
      builder: (sheetContext) {
        final scheme =
            Theme.of(
              sheetContext,
            ).colorScheme;

        return StatefulBuilder(
          builder:
              (
              context,
              setSheetState,
              ) {
            final selectedColor =
            _colorFromHex(
              controller.text,
              fallback:
              scheme.primary,
            );

            return Padding(
              padding:
              EdgeInsets.fromLTRB(
                20,
                4,
                20,
                MediaQuery.of(
                  sheetContext,
                ).viewInsets.bottom +
                    24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration:
                          BoxDecoration(
                            color:
                            selectedColor,
                            borderRadius:
                            BorderRadius
                                .circular(
                              16,
                            ),
                          ),
                          child: Icon(
                            Icons
                                .palette_rounded,
                            color:
                            _contrastColor(
                              selectedColor,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 13,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Text(
                                'Brand Appearance',
                                style: Theme.of(
                                  sheetContext,
                                )
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                  fontWeight:
                                  FontWeight.w800,
                                  letterSpacing:
                                  -.4,
                                ),
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Text(
                                'Choose the color customers will see on your public page.',
                                style: Theme.of(
                                  sheetContext,
                                )
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  color: scheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    Text(
                      'Choose a color',
                      style: Theme.of(
                        sheetContext,
                      )
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children:
                      _brandColorPresets
                          .map(
                            (
                            hex,
                            ) {
                          final color =
                          _colorFromHex(
                            hex,
                          );

                          final selected =
                              _normalizeHexColor(
                                controller
                                    .text,
                              ) ==
                                  hex;

                          return GestureDetector(
                            onTap: () {
                              controller
                                  .text =
                                  hex;

                              setSheetState(
                                    () {},
                              );
                            },
                            child:
                            AnimatedContainer(
                              duration:
                              const Duration(
                                milliseconds:
                                180,
                              ),
                              width: 44,
                              height: 44,
                              decoration:
                              BoxDecoration(
                                color:
                                color,
                                shape:
                                BoxShape
                                    .circle,
                                border:
                                Border.all(
                                  color: selected
                                      ? scheme
                                      .onSurface
                                      : scheme
                                      .surface,
                                  width:
                                  selected
                                      ? 3
                                      : 2,
                                ),
                                boxShadow:
                                selected
                                    ? [
                                  BoxShadow(
                                    color: color.withOpacity(
                                      .35,
                                    ),
                                    blurRadius:
                                    12,
                                  ),
                                ]
                                    : null,
                              ),
                              child:
                              selected
                                  ? Icon(
                                Icons
                                    .check_rounded,
                                color:
                                _contrastColor(
                                  color,
                                ),
                                size:
                                21,
                              )
                                  : null,
                            ),
                          );
                        },
                      )
                          .toList(),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    Text(
                      'Custom HEX color',
                      style: Theme.of(
                        sheetContext,
                      )
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    TextField(
                      controller:
                      controller,
                      textCapitalization:
                      TextCapitalization
                          .characters,
                      onChanged: (_) {
                        setSheetState(
                              () {},
                        );
                      },
                      decoration:
                      InputDecoration(
                        hintText:
                        '#2563EB',
                        prefixIcon:
                        const Icon(
                          Icons
                              .format_color_fill_rounded,
                        ),
                        suffixIcon:
                        Padding(
                          padding:
                          const EdgeInsets
                              .all(
                            8,
                          ),
                          child:
                          Container(
                            width: 30,
                            height: 30,
                            decoration:
                            BoxDecoration(
                              color:
                              selectedColor,
                              shape:
                              BoxShape
                                  .circle,
                            ),
                          ),
                        ),
                        filled: true,
                        fillColor: scheme
                            .surfaceContainerLowest,
                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                            15,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    Container(
                      padding:
                      const EdgeInsets
                          .all(
                        14,
                      ),
                      decoration:
                      BoxDecoration(
                        color: selectedColor
                            .withOpacity(
                          .08,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          17,
                        ),
                        border:
                        Border.all(
                          color: selectedColor
                              .withOpacity(
                            .20,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration:
                            BoxDecoration(
                              color:
                              selectedColor,
                              shape:
                              BoxShape
                                  .circle,
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Text(
                                  'Public page preview',
                                  style: Theme.of(
                                    sheetContext,
                                  )
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                    fontWeight:
                                    FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  controller
                                      .text
                                      .trim()
                                      .isEmpty
                                      ? 'Default ScanAura color'
                                      : controller
                                      .text
                                      .trim()
                                      .toUpperCase(),
                                  style: Theme.of(
                                    sheetContext,
                                  )
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                    color: scheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    SizedBox(
                      width:
                      double.infinity,
                      height: 52,
                      child:
                      FilledButton(
                        onPressed:
                        _brandColorSaving
                            ? null
                            : () async {
                          final value =
                          _normalizeHexColor(
                            controller
                                .text,
                          );

                          if (value ==
                              null) {
                            _showMessage(
                              'Enter a valid HEX color, for example #2563EB.',
                            );
                            return;
                          }

                          _brandColorController
                              .text =
                              value;

                          Navigator.of(
                            sheetContext,
                          ).pop();

                          await _saveBrandColor();
                        },
                        child:
                        _brandColorSaving
                            ? const SizedBox(
                          width: 21,
                          height: 21,
                          child:
                          CircularProgressIndicator(
                            strokeWidth:
                            2,
                          ),
                        )
                            : const Text(
                          'Save Appearance',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    controller.dispose();
  }

  // ============================================================
  // MODERN CARD
  // ============================================================

  Widget _buildModernCard(
      BuildContext context, {
        required Widget child,
      }) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    return Container(
      decoration:
      BoxDecoration(
        color: scheme.surface,
        borderRadius:
        BorderRadius.circular(
          26,
        ),
        border: Border.all(
          color: scheme
              .outlineVariant
              .withOpacity(.42),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(.025),
            blurRadius: 25,
            offset:
            const Offset(
              0,
              8,
            ),
          ),
        ],
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(
          18,
        ),
        child: child,
      ),
    );
  }

  // ============================================================
  // SECTION HEADER
  // ============================================================

  Widget _buildSectionHeader(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
      }) {
    final theme =
    Theme.of(context);

    final scheme =
        theme.colorScheme;

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration:
          BoxDecoration(
            color: scheme
                .primaryContainer,
            borderRadius:
            BorderRadius.circular(
              14,
            ),
          ),
          child: Icon(
            icon,
            size: 21,
            color: scheme
                .onPrimaryContainer,
          ),
        ),
        const SizedBox(
          width: 12,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                  fontWeight:
                  FontWeight.w800,
                  letterSpacing: -.2,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                subtitle,
                style: theme
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                  color: scheme
                      .onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SETTING ROW
  // ============================================================

  Widget _buildSettingRow(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        bool enabled = false,
        bool loading = false,
        bool disabled = false,
        Future<void> Function(
            bool value,
            )? onChanged,
        VoidCallback? onTap,
      }) {
    final theme =
    Theme.of(context);

    final scheme =
        theme.colorScheme;

    return InkWell(
      borderRadius:
      BorderRadius.circular(
        18,
      ),
      onTap:
      disabled ? null : onTap,
      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 2,
        ),
        child: Row(
          children: [
            _buildSmallIconBox(
              context,
              icon,
              disabled:
              disabled,
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: theme
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                            fontWeight:
                            FontWeight.w700,
                            color: disabled
                                ? scheme
                                .onSurfaceVariant
                                : null,
                          ),
                        ),
                      ),
                      if (disabled) ...[
                        const SizedBox(
                          width: 7,
                        ),
                        Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration:
                          BoxDecoration(
                            color: scheme
                                .surfaceContainerHighest,
                            borderRadius:
                            BorderRadius
                                .circular(
                              20,
                            ),
                          ),
                          child: Text(
                            'Soon',
                            style: theme
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    style: theme
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                      color: scheme
                          .onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            if (loading)
              const SizedBox(
                width: 24,
                height: 24,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2.3,
                ),
              )
            else if (onChanged != null)
              Switch.adaptive(
                value: enabled,
                onChanged: disabled
                    ? null
                    : onChanged,
              )
            else
              Icon(
                Icons
                    .chevron_right_rounded,
                color: scheme
                    .onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SMALL ICON BOX
  // ============================================================

  Widget _buildSmallIconBox(
      BuildContext context,
      IconData icon, {
        bool disabled = false,
      }) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    return Container(
      width: 43,
      height: 43,
      decoration:
      BoxDecoration(
        color: scheme
            .surfaceContainerHighest,
        borderRadius:
        BorderRadius.circular(
          14,
        ),
      ),
      child: Icon(
        icon,
        size: 20,
        color: disabled
            ? scheme
            .onSurfaceVariant
            : scheme.onSurface,
      ),
    );
  }

  // ============================================================
  // INLINE INPUT
  // ============================================================

  Widget _buildInlineInput(
      BuildContext context, {
        required TextEditingController
        controller,
        required String label,
        required String hint,
        required TextInputType
        keyboardType,
        required IconData icon,
        required Future<void> Function()
        onSave,
      }) {
    final scheme =
        Theme.of(context)
            .colorScheme;

    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        55,
        0,
        4,
        14,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller:
              controller,
              keyboardType:
              keyboardType,
              decoration:
              InputDecoration(
                labelText:
                label,
                hintText:
                hint,
                prefixIcon:
                Icon(icon),
                isDense:
                true,
                filled:
                true,
                fillColor: scheme
                    .surfaceContainerLowest,
                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius
                      .circular(
                    13,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          SizedBox(
            height: 48,
            child:
            FilledButton(
              onPressed:
              onSave,
              child:
              const Text(
                'Save',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _buildSettingDivider() {
    return const Divider(
      height: 1,
      indent: 55,
    );
  }

  // ============================================================
  // LOADING / EMPTY
  // ============================================================

  Widget _buildLoadingOrEmpty(
      BuildContext context,
      BusinessState state,
      ) {
    if (state.status ==
        BusinessStatus.loading) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    final scheme =
        Theme.of(context)
            .colorScheme;

    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(
          28,
        ),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration:
              BoxDecoration(
                color: scheme
                    .surfaceContainerHighest,
                borderRadius:
                BorderRadius.circular(
                  24,
                ),
              ),
              child: Icon(
                Icons
                    .storefront_outlined,
                size: 36,
                color: scheme
                    .onSurfaceVariant,
              ),
            ),
            const SizedBox(
              height: 18,
            ),
            Text(
              'No business found',
              style: Theme.of(
                context,
              )
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight:
                FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 7,
            ),
            Text(
              state.errorMessage ??
                  'Create your business to continue.',
              textAlign:
              TextAlign.center,
              style: Theme.of(
                context,
              )
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                color: scheme
                    .onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  bool _hasEnabledSocial(
      dynamic business,
      ) {
    return business.instagramEnabled ==
        true ||
        business.facebookEnabled ==
            true ||
        business.youtubeEnabled ==
            true;
  }

  String _contactSummary(
      dynamic business,
      ) {
    final parts =
    <String>[];

    final city =
    business.city
        ?.toString()
        .trim();

    final phone =
    business.phone
        ?.toString()
        .trim();

    if (city != null &&
        city.isNotEmpty) {
      parts.add(city);
    }

    if (phone != null &&
        phone.isNotEmpty) {
      parts.add(phone);
    }

    if (parts.isEmpty) {
      return 'View your saved contact and location details';
    }

    return parts.join(' • ');
  }

  Color _contrastColor(
      Color color,
      ) {
    return color.computeLuminance() >
        0.55
        ? Colors.black
        : Colors.white;
  }

  String _cleanError(
      Object error,
      ) {
    final value =
    error.toString();

    if (value.startsWith(
      'Exception: ',
    )) {
      return value.substring(
        11,
      );
    }

    return value;
  }

// ============================================================
// BRAND COLOR / UI HELPERS
// ============================================================

// ============================================================
// END
// ============================================================
}