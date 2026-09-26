import 'dart:async';
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../activity/loyalty/presentation/pages/customer_loyalty_page.dart';
import '../data/models/landing_response.dart';
import 'providers/public_notifier.dart';
import 'providers/public_state.dart';
import 'theme/public_theme.dart';
import 'theme/public_theme_resolver.dart';

class PublicLandingScreen extends ConsumerStatefulWidget {
  const PublicLandingScreen({
    super.key,
    required this.qrCode,
    required this.onOpenMenu,
    required this.onOpenPayment,
  });

  final String qrCode;
  final VoidCallback onOpenMenu;
  final VoidCallback onOpenPayment;

  @override
  ConsumerState<PublicLandingScreen> createState() =>
      _PublicLandingScreenState();
}

class _PublicLandingScreenState
    extends ConsumerState<PublicLandingScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(publicNotifierProvider.notifier)
          .loadLanding(widget.qrCode);
    });
  }

  // ===========================================================================
  // SHARE
  // ===========================================================================

  Future<void> _sharePage() async {
    final currentUrl = Uri.base.toString();

    final landing =
        ref.read(publicNotifierProvider).landing;

    final businessName =
    landing?.businessName.trim().isNotEmpty == true
        ? landing!.businessName.trim()
        : 'this business';

    final terminology = _terminologyFor(
      landing?.businessType ?? '',
    );

    final shareText =
        'Check out $businessName on ScanAura.\n\n'
        'Explore their digital '
        '${terminology.collectionTitle.toLowerCase()} '
        'and offerings:\n'
        '$currentUrl';

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: shareText,
          title: 'Check out $businessName',
        ),
      );
    } catch (_) {
      await Clipboard.setData(
        ClipboardData(text: shareText),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Share message copied to clipboard.',
          ),
        ),
      );
    }
  }

  // ===========================================================================
  // EXTERNAL LINK
  // ===========================================================================

  Future<void> _openExternalLink(String url) async {
    final normalized = url.trim();

    if (normalized.isEmpty) {
      return;
    }

    final uri = Uri.tryParse(normalized);

    if (uri == null ||
        !uri.hasScheme ||
        (!uri.isScheme('http') &&
            !uri.isScheme('https'))) {
      _showMessage('Unable to open this link.');
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showMessage('Unable to open this link.');
      }
    } catch (_) {
      _showMessage('Unable to open this link.');
    }
  }

  // ===========================================================================
  // CALL
  // ===========================================================================

  Future<void> _callBusiness(String phone) async {
    final normalized =
    phone.replaceAll(RegExp(r'[^\d+]'), '');

    if (normalized.isEmpty) {
      return;
    }

    final uri = Uri(
      scheme: 'tel',
      path: normalized,
    );

    try {
      final launched = await launchUrl(uri);

      if (!launched) {
        _showMessage('Unable to start the call.');
      }
    } catch (_) {
      _showMessage('Unable to start the call.');
    }
  }

  // ===========================================================================
  // WHATSAPP
  // ===========================================================================

  Future<void> _openWhatsApp(String phone) async {
    final digits = phone.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (digits.isEmpty) {
      return;
    }

    final message =
        'Hi, I found your business on ScanAura.';

    final uri = Uri.parse(
      'https://wa.me/$digits'
          '?text=${Uri.encodeComponent(message)}',
    );

    await _openExternalLink(uri.toString());
  }

  // ===========================================================================
  // MESSAGE
  // ===========================================================================

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(publicNotifierProvider);

    if (state.status == PublicStatus.loading &&
        state.landing == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final landing = state.landing;

    if (landing == null) {
      return _Failure(
        message: state.isBusinessUnavailable
            ? 'This business page is unavailable right now.'
            : 'We could not open this business page.',
        retry: () {
          ref
              .read(publicNotifierProvider.notifier)
              .loadLanding(widget.qrCode);
        },
      );
    }

    final theme = PublicThemeResolver.resolve(
      businessName: landing.businessName,
      businessType: landing.businessType,
      brandColor: landing.brandColor,
    );

    final materialTheme = theme.materialTheme(context);

    return Theme(
      data: materialTheme,
      child: Scaffold(
        backgroundColor:
        materialTheme.scaffoldBackgroundColor,
        body: SafeArea(
          child: _LandingContent(
            landing: landing,
            theme: theme,
            onShare: _sharePage,
            onOpenMenu: widget.onOpenMenu,
            onCall: _callBusiness,
            onWhatsApp: _openWhatsApp,
            onOpenExternalLink: _openExternalLink,
            onShowMessage: _showMessage,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// LANDING CONTENT
// =============================================================================

class _LandingContent extends StatelessWidget {
  const _LandingContent({
    required this.landing,
    required this.theme,
    required this.onShare,
    required this.onOpenMenu,
    required this.onCall,
    required this.onWhatsApp,
    required this.onOpenExternalLink,
    required this.onShowMessage,
  });

  final LandingResponse landing;
  final PublicTheme theme;

  final VoidCallback onShare;
  final VoidCallback onOpenMenu;

  final Future<void> Function(String phone) onCall;
  final Future<void> Function(String phone) onWhatsApp;
  final Future<void> Function(String url) onOpenExternalLink;

  final void Function(String message) onShowMessage;

  // ===========================================================================
  // BASIC DATA
  // ===========================================================================

  String get businessName {
    final value = landing.businessName.trim();

    return value.isEmpty ? 'Business' : value;
  }

  String get businessTypeLabel {
    switch (landing.businessType.trim().toUpperCase()) {
      case 'FOOD':
        return 'Food';

      case 'HOTEL':
        return 'Hotel';

      case 'RETAIL':
        return 'Retail';

      case 'ECOMMERCE':
      case 'E_COMMERCE':
        return 'E-commerce';

      case 'SERVICES':
        return 'Services';

      case 'PERSONAL_BRAND':
        return 'Personal Brand';

      case 'OTHER':
        return 'Other';

      default:
        final value = landing.businessType.trim();

        if (value.isEmpty) {
          return 'Business';
        }

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

  bool get isFood {
    const foodTypes = {
      'FOOD',
      'RESTAURANT',
      'CAFE',
      'BAKERY',
    };

    return foodTypes.contains(
      landing.businessType.trim().toUpperCase(),
    );
  }

  String get primaryActionLabel {
    if (isFood) {
      return 'Open Menu';
    }

    switch (
    landing.businessType.trim().toUpperCase()) {
      case 'HOTEL':
        return 'Explore Rooms & Menu';

      case 'SERVICES':
      case 'SALON':
        return 'Explore Services';

      case 'ECOMMERCE':
      case 'E_COMMERCE':
        return 'Explore Products';

      case 'RETAIL':
      case 'RETAIL_SHOP':
        return 'Explore Catalogue';

      case 'PERSONAL_BRAND':
        return 'Explore Offerings';

      default:
        return 'Explore';
    }
  }

  String get primaryDescription {
    if (isFood) {
      return 'Take a look at the menu and discover something you will love.';
    }

    switch (
    landing.businessType.trim().toUpperCase()) {
      case 'HOTEL':
        return 'Explore rooms, food menu and other offerings from this hotel.';

      case 'SERVICES':
        return 'Explore available services and offerings.';

      case 'RETAIL':
      case 'ECOMMERCE':
      case 'E_COMMERCE':
        return 'Browse available products and offerings.';

      default:
        return 'Explore products, services and offerings.';
    }
  }

  // ===========================================================================
  // FEATURE CHECKS
  // ===========================================================================

  bool get hasLogo =>
      landing.logoUrl != null &&
          landing.logoUrl!.trim().isNotEmpty;

  bool get hasAddress {
    return [
      landing.address,
      landing.city,
      landing.state,
      landing.country,
      landing.pincode,
    ].any(
          (value) =>
      value != null &&
          value.trim().isNotEmpty,
    );
  }

  bool get hasMaps =>
      landing.mapsEnabled == true &&
          landing.googleMapsUrl != null &&
          landing.googleMapsUrl!.trim().isNotEmpty;

  bool get hasCall =>
      landing.callEnabled == true &&
          landing.phone != null &&
          landing.phone!.trim().isNotEmpty;

  bool get hasWhatsApp =>
      landing.whatsappEnabled == true &&
          landing.whatsapp != null &&
          landing.whatsapp!.trim().isNotEmpty;

  bool get hasGallery =>
      landing.galleryEnabled == true &&
          landing.galleryImages.isNotEmpty;

  bool get hasReview =>
      landing.googleReviewEnabled == true &&
          landing.googleReviewUrl != null &&
          landing.googleReviewUrl!.trim().isNotEmpty;

  bool get hasLoyalty =>
      landing.loyaltyEnabled == true;

  bool get hasInstagram =>
      landing.instagramEnabled == true &&
          landing.instagramUrl != null &&
          landing.instagramUrl!.trim().isNotEmpty;

  bool get hasFacebook =>
      landing.facebookEnabled == true &&
          landing.facebookUrl != null &&
          landing.facebookUrl!.trim().isNotEmpty;

  bool get hasYoutube =>
      landing.youtubeEnabled == true &&
          landing.youtubeUrl != null &&
          landing.youtubeUrl!.trim().isNotEmpty;

  bool get hasSocials =>
      hasInstagram ||
          hasFacebook ||
          hasYoutube;

  // ===========================================================================
  // ADDRESS
  // ===========================================================================

  String get fullAddress {
    final parts = <String>[];

    void add(String? value) {
      final trimmed = value?.trim() ?? '';

      if (trimmed.isNotEmpty) {
        parts.add(trimmed);
      }
    }

    add(landing.address);
    add(landing.city);
    add(landing.state);
    add(landing.country);
    add(landing.pincode);

    return parts.join(', ');
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final horizontalPadding = width < 360
            ? 16.0
            : width < 600
            ? 20.0
            : width < 1000
            ? 28.0
            : 36.0;

        final maxWidth = width >= 1200
            ? 860.0
            : width >= 900
            ? 780.0
            : 620.0;

        return Stack(
          children: [
            RefreshIndicator(
              color: theme.primary,
              onRefresh: () async {
                await Future<void>.delayed(
                  const Duration(milliseconds: 100),
                );
              },
              child: SingleChildScrollView(
                physics:
                const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  14,
                  horizontalPadding,
                  35,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxWidth,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                      children: [
                        _buildHero(context),

                        const SizedBox(height: 18),

                        _buildExploreCard(context),

                        if (hasGallery) ...[
                          const SizedBox(height: 18),
                          _buildGallerySection(context),
                        ],

                        if (hasReview) ...[
                          const SizedBox(height: 18),
                          _buildReviewCard(context),
                        ],

                        if (hasLoyalty) ...[
                          const SizedBox(height: 18),
                          _buildExperienceCard(context),
                        ],

                        if (hasSocials) ...[
                          const SizedBox(height: 24),
                          _buildSocialSection(context),
                        ],

                        const SizedBox(height: 30),

                        _buildFooter(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            if (hasWhatsApp)
              Positioned(
                right: 18,
                bottom: 18,
                child: _WhatsAppFloatingButton(
                  onTap: () {
                    onWhatsApp(
                      landing.whatsapp!,
                    );
                  },
                  theme: theme,
                ),
              ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // 1. HERO
  // ===========================================================================

  Widget _buildHero(BuildContext context) {
    return _HeroCard(
      theme: theme,
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -70,
            child: _GlowOrb(
              color: theme.primary.withValues(
                alpha: 0.13,
              ),
              size: 190,
            ),
          ),

          Positioned(
            bottom: -100,
            left: -90,
            child: _GlowOrb(
              color: theme.accent.withValues(
                alpha: 0.10,
              ),
              size: 200,
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              24,
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: _HeroIconButton(
                    icon: Icons.share_rounded,
                    tooltip: 'Share',
                    color: theme.primary,
                    onTap: onShare,
                  ),
                ),

                const SizedBox(height: 8),

                _BusinessLogo(
                  logoUrl:
                  hasLogo ? landing.logoUrl : null,
                  businessName: businessName,
                  theme: theme,
                  size: 118,
                ),

                const SizedBox(height: 18),

                Text(
                  businessName,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 30,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                  ),
                ),

                const SizedBox(height: 9),

                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                    theme.primary.withValues(
                      alpha: .08,
                    ),
                    borderRadius:
                    BorderRadius.circular(30),
                  ),
                  child: Text(
                    businessTypeLabel,
                    style: TextStyle(
                      color: theme.primary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                if (hasAddress) ...[
                  const SizedBox(height: 16),

                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: hasMaps
                          ? () {
                        onOpenExternalLink(
                          landing.googleMapsUrl!,
                        );
                      }
                          : null,
                      borderRadius:
                      BorderRadius.circular(16),
                      child: Ink(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primary
                              .withValues(alpha: .055),
                          borderRadius:
                          BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.primary
                                .withValues(alpha: .10),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: theme.primary
                                    .withValues(
                                  alpha: .10,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.location_on_outlined,
                                color: theme.primary,
                                size: 19,
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Location',
                                    style: TextStyle(
                                      color:
                                      theme.textTertiary,
                                      fontSize: 10.5,
                                      fontWeight:
                                      FontWeight.w700,
                                    ),
                                  ),

                                  const SizedBox(height: 3),

                                  Text(
                                    fullAddress,
                                    style: TextStyle(
                                      color:
                                      theme.textPrimary,
                                      fontSize: 12.5,
                                      height: 1.4,
                                      fontWeight:
                                      FontWeight.w600,
                                    ),
                                  ),

                                  if (hasMaps) ...[
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons
                                              .directions_outlined,
                                          size: 14,
                                          color:
                                          theme.primary,
                                        ),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        Text(
                                          'Get directions',
                                          style: TextStyle(
                                            color:
                                            theme.primary,
                                            fontSize: 11,
                                            fontWeight:
                                            FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            if (hasMaps)
                              Padding(
                                padding:
                                const EdgeInsets.only(
                                  left: 6,
                                  top: 7,
                                ),
                                child: Icon(
                                  Icons
                                      .arrow_forward_ios_rounded,
                                  size: 14,
                                  color:
                                  theme.primary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                if (hasCall) ...[
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () {
                        onCall(
                          landing.phone!,
                        );
                      },
                      icon: const Icon(
                        Icons.phone_outlined,
                        size: 19,
                      ),
                      label: const Text(
                        'Call Business',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primary
                        .withValues(alpha: .07),
                    borderRadius:
                    BorderRadius.circular(30),
                    border: Border.all(
                      color: theme.primary
                          .withValues(alpha: .11),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: theme.primary,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'Your digital experience',
                        style: TextStyle(
                          color: theme.primary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. MENU / CATALOGUE
  // ===========================================================================

  Widget _buildExploreCard(BuildContext context) {
    return _GlassCard(
      theme: theme,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            'Explore what we have for you',
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 21,
              height: 1.15,
              fontWeight: FontWeight.w800,
              letterSpacing: -.5,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            primaryDescription,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 13.5,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: landing.menuAvailable
                  ? onOpenMenu
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: theme.onPrimary,
                disabledBackgroundColor:
                theme.primary.withValues(
                  alpha: .25,
                ),
                disabledForegroundColor:
                theme.onPrimary.withValues(
                  alpha: .75,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(17),
                ),
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    isFood
                        ? Icons
                        .restaurant_menu_rounded
                        : Icons.grid_view_rounded,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    primaryActionLabel,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 19,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 3. GALLERY
  // ===========================================================================

  Widget _buildGallerySection(BuildContext context) {
    final images = [...landing.galleryImages]
      ..sort(
            (a, b) =>
            a.displayOrder.compareTo(b.displayOrder),
      );

    final validImages = images
        .where(
          (image) =>
      image.imageUrl.trim().isNotEmpty,
    )
        .toList();

    if (validImages.isEmpty) {
      return const SizedBox.shrink();
    }

    return _GalleryCarousel(
      images: validImages,
      theme: theme,
      onOpenViewer: (index) {
        _openGalleryViewer(
          context,
          validImages,
          index,
        );
      },
    );
  }

  void _openGalleryViewer(
      BuildContext context,
      List<PublicGalleryImage> images,
      int initialIndex,
      ) {
    showDialog<void>(
      context: context,
      barrierColor:
      Colors.black.withValues(alpha: .94),
      builder: (dialogContext) {
        final controller =
        PageController(
          initialPage: initialIndex,
        );

        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              PageView.builder(
                controller: controller,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: Image.network(
                        images[index].imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (_, __, ___) {
                          return const Icon(
                            Icons
                                .broken_image_outlined,
                            color: Colors.white,
                            size: 50,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),

              Positioned(
                top: 18,
                right: 18,
                child: SafeArea(
                  child: Material(
                    color: Colors.white
                        .withValues(alpha: .18),
                    shape:
                    const CircleBorder(),
                    child: InkWell(
                      customBorder:
                      const CircleBorder(),
                      onTap: () {
                        Navigator.of(
                          dialogContext,
                        ).pop();
                      },
                      child: const SizedBox(
                        width: 46,
                        height: 46,
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // 4. GOOGLE REVIEW
  // ===========================================================================

  Widget _buildReviewCard(BuildContext context) {
    return _GlassCard(
      theme: theme,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: theme.primary.withValues(
                    alpha: .10,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.rate_review_outlined,
                  color: theme.primary,
                  size: 25,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enjoyed your experience?',
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Share your experience with us on Google.',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: () {
                onOpenExternalLink(
                  landing.googleReviewUrl!,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: theme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.rate_review_rounded,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Review us',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 19,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 5. ENJOY MORE WITH US
  // ===========================================================================

  Widget _buildExperienceCard(BuildContext context) {
    if (!hasLoyalty) {
      return const SizedBox.shrink();
    }

    return _GlassCard(
      theme: theme,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            'Enjoy more with us',
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 21,
              height: 1.15,
              fontWeight: FontWeight.w800,
              letterSpacing: -.5,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'Discover more ways to enjoy your experience with this business.',
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 13.5,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 18),

          _ExperienceAction(
            icon: Icons.loyalty_rounded,
            label: 'Loyalty',
            color: theme.primary,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      CustomerLoyaltyPage(
                        businessId: landing.businessId,
                        businessName: businessName,
                        businessType:
                        landing.businessType,
                        brandColor:
                        landing.brandColor,
                      ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 6. CONNECT WITH US
  // ===========================================================================

  Widget _buildSocialSection(BuildContext context) {
    final socials = <_SocialItem>[];

    if (hasInstagram) {
      socials.add(
        _SocialItem(
          label: 'Instagram',
          icon: Icons.camera_alt_outlined,
          url: landing.instagramUrl!,
        ),
      );
    }

    if (hasFacebook) {
      socials.add(
        _SocialItem(
          label: 'Facebook',
          icon: Icons.facebook_rounded,
          url: landing.facebookUrl!,
        ),
      );
    }

    if (hasYoutube) {
      socials.add(
        _SocialItem(
          label: 'YouTube',
          icon:
          Icons.play_circle_outline_rounded,
          url: landing.youtubeUrl!,
        ),
      );
    }

    if (socials.isEmpty) {
      return const SizedBox.shrink();
    }

    return _GlassCard(
      theme: theme,
      padding: const EdgeInsets.fromLTRB(
        22,
        24,
        22,
        24,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.center,
        children: [
          Text(
            'Connect with us',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              letterSpacing: -.5,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'Stay connected with this business.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 13.5,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.center,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              for (
              int index = 0;
              index < socials.length;
              index++
              ) ...[
                SizedBox(
                  width: 86,
                  child: _SocialDot(
                    item: socials[index],
                    theme: theme,
                    onTap: () {
                      onOpenExternalLink(
                        socials[index].url,
                      );
                    },
                  ),
                ),
                if (index != socials.length - 1)
                  const SizedBox(width: 18),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // FOOTER
  // ===========================================================================

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Text(
          'Powered by ScanAura',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 2),

        TextButton(
          onPressed: () {
            context.go('/register');
          },
          style: TextButton.styleFrom(
            foregroundColor: theme.primary,
            padding:
            const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            minimumSize: Size.zero,
            tapTargetSize:
            MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Register your business',
                style: TextStyle(
                  color: theme.primary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                Icons.arrow_forward_rounded,
                size: 15,
                color: theme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// GALLERY CAROUSEL
// =============================================================================

class _GalleryCarousel extends StatefulWidget {
  const _GalleryCarousel({
    required this.images,
    required this.theme,
    required this.onOpenViewer,
  });

  final List<PublicGalleryImage> images;
  final PublicTheme theme;
  final ValueChanged<int> onOpenViewer;

  @override
  State<_GalleryCarousel> createState() =>
      _GalleryCarouselState();
}

class _GalleryCarouselState
    extends State<_GalleryCarousel> {
  late final PageController _pageController;

  Timer? _autoSlideTimer;

  int _currentIndex = 0;

  bool _isUserDragging = false;

  @override
  void initState() {
    super.initState();

    final count = widget.images.length;

    final initialPage = count > 1
        ? count * 1000
        : 0;

    _currentIndex = 0;

    _pageController = PageController(
      initialPage: initialPage,
      viewportFraction:
      count > 1 ? 0.88 : 1.0,
    );

    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();

    if (widget.images.length <= 1) {
      return;
    }

    _autoSlideTimer = Timer.periodic(
      const Duration(seconds: 4),
          (_) {
        if (!mounted ||
            !_pageController.hasClients ||
            _isUserDragging) {
          return;
        }

        _pageController.nextPage(
          duration:
          const Duration(milliseconds: 650),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  void _pauseAutoSlide() {
    _autoSlideTimer?.cancel();
  }

  void _resumeAutoSlide() {
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.images.length;

    return _GlassCard(
      theme: widget.theme,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Gallery',
                  style: TextStyle(
                    color: widget.theme.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.4,
                  ),
                ),
              ),

              Text(
                '$count ${count == 1 ? 'photo' : 'photos'}',
                style: TextStyle(
                  color: widget.theme.textTertiary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            height: 230,
            child: Listener(
              onPointerDown: (_) {
                _isUserDragging = true;
                _pauseAutoSlide();
              },
              onPointerUp: (_) {
                _isUserDragging = false;
                _resumeAutoSlide();
              },
              onPointerCancel: (_) {
                _isUserDragging = false;
                _resumeAutoSlide();
              },
              child: ScrollConfiguration(
                behavior:
                const _GalleryScrollBehavior(),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: count > 1
                      ? count * 10000
                      : 1,
                  onPageChanged: (page) {
                    if (!mounted) {
                      return;
                    }

                    setState(() {
                      _currentIndex =
                          page % count;
                    });
                  },
                  itemBuilder:
                      (context, page) {
                    final index =
                        page % count;

                    final image =
                    widget.images[index];

                    return Padding(
                      padding: EdgeInsets.only(
                        right:
                        count > 1 ? 10 : 0,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          widget.onOpenViewer(
                            index,
                          );
                        },
                        child: ClipRRect(
                          borderRadius:
                          BorderRadius.circular(
                            18,
                          ),
                          child: Image.network(
                            image.imageUrl,
                            width:
                            double.infinity,
                            height: 230,
                            fit: BoxFit.cover,
                            loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                                ) {
                              if (loadingProgress ==
                                  null) {
                                return child;
                              }

                              return Container(
                                color: widget
                                    .theme
                                    .primary
                                    .withValues(
                                  alpha: .05,
                                ),
                                child: Center(
                                  child:
                                  CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: widget
                                        .theme
                                        .primary,
                                  ),
                                ),
                              );
                            },
                            errorBuilder:
                                (_, __, ___) {
                              return Container(
                                color: widget
                                    .theme
                                    .primary
                                    .withValues(
                                  alpha: .05,
                                ),
                                child: Icon(
                                  Icons
                                      .broken_image_outlined,
                                  color: widget
                                      .theme
                                      .textTertiary,
                                  size: 35,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          if (count > 1) ...[
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: List.generate(
                count,
                    (index) {
                  final active =
                      index == _currentIndex;

                  return AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 250,
                    ),
                    margin:
                    const EdgeInsets.symmetric(
                      horizontal: 3,
                    ),
                    width:
                    active ? 18 : 6,
                    height: 6,
                    decoration:
                    BoxDecoration(
                      color: active
                          ? widget
                          .theme
                          .primary
                          : widget
                          .theme
                          .primary
                          .withValues(
                        alpha: .20,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        10,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// GALLERY SCROLL BEHAVIOR
// =============================================================================

class _GalleryScrollBehavior
    extends MaterialScrollBehavior {
  const _GalleryScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

// =============================================================================
// EXPERIENCE ACTION
// =============================================================================

class _ExperienceAction extends StatelessWidget {
  const _ExperienceAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(17),
        child: Ink(
          width: double.infinity,
          padding:
          const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: color.withValues(
              alpha: .07,
            ),
            borderRadius:
            BorderRadius.circular(17),
            border: Border.all(
              color: color.withValues(
                alpha: .13,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(
                    alpha: .10,
                  ),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: color,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SOCIAL
// =============================================================================

class _SocialItem {
  const _SocialItem({
    required this.label,
    required this.icon,
    required this.url,
  });

  final String label;
  final IconData icon;
  final String url;
}

class _SocialDot extends StatelessWidget {
  const _SocialDot({
    required this.item,
    required this.theme,
    required this.onTap,
  });

  final _SocialItem item;
  final PublicTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(18),
        child: Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 5,
            vertical: 3,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Ink(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.primary
                      .withValues(alpha: .07),
                  border: Border.all(
                    color: theme.primary
                        .withValues(alpha: .12),
                  ),
                ),
                child: Icon(
                  item.icon,
                  size: 20,
                  color: theme.primary,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                item.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// WHATSAPP FLOATING BUTTON
// =============================================================================

class _WhatsAppFloatingButton extends StatelessWidget {
  const _WhatsAppFloatingButton({
    required this.onTap,
    required this.theme,
  });

  final VoidCallback onTap;
  final PublicTheme theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: theme.primary,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.chat_bubble_rounded,
              size: 27,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
// =============================================================================
// HERO CARD
// =============================================================================

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.theme,
    required this.child,
  });

  final PublicTheme theme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.glassSurface,
        borderRadius:
        BorderRadius.circular(30),
        border: Border.all(
          color: theme.glassBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withValues(
              alpha: .08,
            ),
            blurRadius: 35,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin:
                    Alignment.topLeft,
                    end:
                    Alignment.bottomRight,
                    colors: [
                      theme.primary
                          .withValues(alpha: .035),
                      Colors.transparent,
                      theme.accent
                          .withValues(alpha: .025),
                    ],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

// =============================================================================
// GLASS CARD
// =============================================================================

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.theme,
    required this.child,
    this.padding =
    const EdgeInsets.all(20),
  });

  final PublicTheme theme;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.glassSurface,
        borderRadius:
        BorderRadius.circular(28),
        border: Border.all(
          color: theme.glassBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withValues(
              alpha: .055,
            ),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin:
                      Alignment.topLeft,
                      end:
                      Alignment.bottomRight,
                      colors: [
                        theme.primary
                            .withValues(
                          alpha: .035,
                        ),
                        Colors.transparent,
                        theme.accent
                            .withValues(
                          alpha: .025,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: padding,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// HERO ICON BUTTON
// =============================================================================

class _HeroIconButton extends StatelessWidget {
  const _HeroIconButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(16),
        child: Ink(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withValues(
              alpha: .08,
            ),
            borderRadius:
            BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(
                alpha: .13,
              ),
            ),
          ),
          child: Tooltip(
            message: tooltip,
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// BUSINESS LOGO
// =============================================================================

class _BusinessLogo extends StatelessWidget {
  const _BusinessLogo({
    required this.logoUrl,
    required this.businessName,
    required this.theme,
    this.size = 118,
  });

  final String? logoUrl;
  final String businessName;
  final PublicTheme theme;
  final double size;

  String get initials {
    final parts = businessName
        .split(RegExp(r'\s+'))
        .where(
          (part) => part.isNotEmpty,
    )
        .take(2)
        .toList();

    if (parts.isEmpty) {
      return 'B';
    }

    return parts
        .map(
          (part) => part.substring(0, 1),
    )
        .join()
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasLogo =
        logoUrl != null &&
            logoUrl!.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primary.withValues(
              alpha: .15,
            ),
            theme.primary.withValues(
              alpha: .045,
            ),
          ],
        ),
        border: Border.all(
          color: theme.primary.withValues(
            alpha: .18,
          ),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withValues(
              alpha: .11,
            ),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: hasLogo
          ? Image.network(
        logoUrl!,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) {
          return _fallback();
        },
      )
          : _fallback(),
    );
  }

  Widget _fallback() {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: theme.primary,
          fontSize: 33,
          fontWeight: FontWeight.w900,
          letterSpacing: -.5,
        ),
      ),
    );
  }
}

// =============================================================================
// GLOW
// =============================================================================

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

// =============================================================================
// FAILURE
// =============================================================================

class _Failure extends StatelessWidget {
  const _Failure({
    required this.message,
    required this.retry,
  });

  final String message;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding:
            const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Icon(
                    Icons
                        .error_outline_rounded,
                    size: 54,
                    color: Theme.of(context)
                        .colorScheme
                        .error,
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  const Text(
                    'Unable to open this page',
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    message,
                    textAlign:
                    TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: retry,
                      icon: const Icon(
                        Icons.refresh_rounded,
                      ),
                      label:
                      const Text('Retry'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// TERMINOLOGY
// =============================================================================

class _PublicTerminology {
  const _PublicTerminology({
    required this.collectionTitle,
    required this.itemTitle,
  });

  final String collectionTitle;
  final String itemTitle;
}

_PublicTerminology _terminologyFor(
    String businessType,
    ) {
  switch (
  businessType.trim().toUpperCase()) {
    case 'FOOD':
      return const _PublicTerminology(
        collectionTitle: 'Menu',
        itemTitle: 'Item',
      );

    case 'HOTEL':
      return const _PublicTerminology(
        collectionTitle: 'Menu',
        itemTitle: 'Item',
      );

    case 'SERVICES':
      return const _PublicTerminology(
        collectionTitle: 'Services',
        itemTitle: 'Service',
      );

    case 'RETAIL':
    case 'ECOMMERCE':
    case 'E_COMMERCE':
      return const _PublicTerminology(
        collectionTitle: 'Catalog',
        itemTitle: 'Product',
      );

    case 'PERSONAL_BRAND':
    case 'OTHER':
    default:
      return const _PublicTerminology(
        collectionTitle: 'Catalog',
        itemTitle: 'Item',
      );
  }
}