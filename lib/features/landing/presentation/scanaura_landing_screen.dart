import 'package:flutter/material.dart';

class ScanAuraLandingScreen extends StatefulWidget {
  const ScanAuraLandingScreen({
    super.key,
    required this.onGetStarted,
    required this.onLogin,
    this.onSkip,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onLogin;
  final VoidCallback? onSkip;

  @override
  State<ScanAuraLandingScreen> createState() =>
      _ScanAuraLandingScreenState();
}

class _ScanAuraLandingScreenState extends State<ScanAuraLandingScreen> {
  late final PageController _pageController;

  int _currentPage = 0;

  static const int _pageCount = 5;

  // Fixed design canvas.
  // The whole canvas scales down on smaller screens instead
  // of allowing individual elements to stretch.
  static const double _designWidth = 760;
  static const double _designHeight = 500;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  void _goToPage(int page) {
    final target = page.clamp(0, _pageCount - 1);

    _pageController.animateToPage(
      target,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _next() {
    if (_currentPage == _pageCount - 1) {
      widget.onGetStarted();
      return;
    }

    _goToPage(_currentPage + 1);
  }

  void _previous() {
    if (_currentPage == 0) {
      return;
    }

    _goToPage(_currentPage - 1);
  }

  void _skip() {
    if (widget.onSkip != null) {
      widget.onSkip!();
      return;
    }

    _goToPage(_pageCount - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pageCount,
                physics: const PageScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(context, index);
                },
              ),
            ),

            _buildNavigation(context),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          _buildBrand(context),
          const Spacer(),
          if (_currentPage < _pageCount - 1)
            TextButton(
              onPressed: _skip,
              child: const Text('Skip'),
            ),
        ],
      ),
    );
  }

  Widget _buildBrand(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/scanaura_logo.png',
          width: 32,
          height: 32,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        Text(
          'ScanAura',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PAGES
  // ============================================================

  Widget _buildPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        return _buildPage1(context);

      case 1:
        return _buildPage2(context);

      case 2:
        return _buildPage3(context);

      case 3:
        return _buildPage4(context);

      case 4:
        return _buildPage5(context);

      default:
        return const SizedBox.shrink();
    }
  }

  // ============================================================
  // SLIDE 1
  // ============================================================

  Widget _buildPage1(BuildContext context) {
    return _buildCenteredSlide(
      context,
      pill: 'Digital business presence',
      pillUsesPrimary: true,
      title: 'Your Business. One QR.',
      subtitle: 'Go digital in minutes.',
      visual: _buildBusinessFlow(context),
    );
  }

  // ============================================================
  // SLIDE 2
  // ============================================================

  Widget _buildPage2(BuildContext context) {
    return _buildCenteredSlide(
      context,
      pill: 'AI Import',
      pillUsesPrimary: true,
      title: 'Already have a menu or catalog?',
      subtitle: 'Let AI import it.',
      hint: 'Less manual work.',
      visual: _buildAiFlow(context),
    );
  }

  // ============================================================
  // SLIDE 3
  // ============================================================

  Widget _buildPage3(BuildContext context) {
    return _buildCenteredSlide(
      context,
      pill: 'For every business',
      pillUsesPrimary: true,
      title: 'Built for every business.',
      subtitle: 'One platform. Any business.',
      visual: _buildBusinessTypeGrid(context),
    );
  }

  // ============================================================
  // SLIDE 4
  // ============================================================

  Widget _buildPage4(BuildContext context) {
    return _buildCenteredSlide(
      context,
      pill: 'One QR, many possibilities',
      pillUsesPrimary: true,
      title: 'Scan. View. Pay.',
      subtitle: 'One QR. One digital destination.',
      visual: _buildScanViewPay(context),
    );
  }

  // ============================================================
  // SLIDE 5
  // ============================================================

  Widget _buildPage5(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _buildCenteredSlide(
        context,
        pill: 'Simple & affordable',
        pillUsesPrimary: true,
        title: 'Go digital from ₹99/month.',
        subtitle: 'Start simple. Grow with ScanAura.',
      visual: _buildWhiteCard(
        context,
        maxWidth: 410,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 26,
            vertical: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPill(
                context,
                'Starting plan',
              ),

              const SizedBox(height: 20),

              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '₹99',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.2,
                      ),
                    ),
                    TextSpan(
                      text: ' / month',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Your digital business presence. One QR. Start simple.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),

              const SizedBox(height: 18),

              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton(
                    onPressed: widget.onGetStarted,
                    child: const Text('Get Started'),
                  ),
                  OutlinedButton(
                    onPressed: widget.onLogin,
                    child: const Text('Log In'),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Text(
                'Scan. View. Pay.',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // COMMON SLIDE LAYOUT
  // Fixed presentation canvas.
  // ============================================================

  Widget _buildCenteredSlide(
      BuildContext context, {
        required Widget visual,
        required String title,
        required String subtitle,
        String? pill,
        String? hint,
        bool pillUsesPrimary = false,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: _designWidth,
            height: _designHeight,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 22,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: colorScheme.outlineVariant,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(
                      alpha: 0.10,
                    ),
                    blurRadius: 28,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // -------------------------------------------------
                  // PILL
                  // -------------------------------------------------

                  if (pill != null) ...[
                    _buildPill(
                      context,
                      pill,
                      usePrimary: pillUsesPrimary,
                    ),
                    const SizedBox(height: 10),
                  ],

                  // -------------------------------------------------
                  // TITLE
                  // -------------------------------------------------

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.0,
                      height: 1.02,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // -------------------------------------------------
                  // SUBTITLE
                  // -------------------------------------------------

                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // -------------------------------------------------
                  // HINT
                  // -------------------------------------------------

                  if (hint != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      hint,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],

                  const SizedBox(height: 10),

                  // -------------------------------------------------
                  // FIXED VISUAL AREA
                  //
                  // IMPORTANT:
                  // Do NOT use Expanded here.
                  // The visual has its own design size and is scaled
                  // as a complete unit when necessary.
                  // -------------------------------------------------

                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: visual,
                      ),
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
  Widget _buildWhiteCard(
      BuildContext context, {
        required Widget child,
        double maxWidth = 900,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: colorScheme.outlineVariant,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(
                alpha: 0.10,
              ),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _buildPill(
      BuildContext context,
      String text, {
        bool usePrimary = false,
      }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: usePrimary
            ? colorScheme.primary
            : colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: usePrimary
              ? colorScheme.onPrimary
              : colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }

  // ============================================================
  // SLIDE 1
  // BUSINESS -> LOGO IMAGE -> CUSTOMER
  // ============================================================

  Widget _buildBusinessFlow(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildFlowNode(
          context,
          icon: Icons.storefront_outlined,
          label: 'Business',
        ),

        const SizedBox(width: 22),

        _buildHorizontalConnector(context),

        const SizedBox(width: 22),

        // No green/primary decoration.
        // Keep only the actual ScanAura logo image.
        _buildLogoImage(
          size: 118,
        ),

        const SizedBox(width: 22),

        _buildHorizontalConnector(context),

        const SizedBox(width: 22),

        _buildFlowNode(
          context,
          icon: Icons.smartphone_outlined,
          label: 'Customer',
        ),
      ],
    );
  }

  Widget _buildFlowNode(
      BuildContext context, {
        required IconData icon,
        required String label,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 150,
      height: 74,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(
              alpha: 0.08,
            ),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 19,
              color: colorScheme.primary,
            ),
          ),

          const SizedBox(width: 9),

          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoImage({
    required double size,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/scanaura_logo_white.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildHorizontalConnector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 34,
      height: 2,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(
          alpha: 0.40,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // ============================================================
  // SLIDE 2
  // ============================================================

  Widget _buildAiFlow(BuildContext context) {
    return SizedBox(
      width: 590,
      height: 150,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildOldListCard(
            context,
            width: 175,
          ),

          const SizedBox(width: 14),

          _buildHorizontalConnector(context),

          const SizedBox(width: 14),

          _buildAiCircle(context),

          const SizedBox(width: 14),

          _buildHorizontalConnector(context),

          const SizedBox(width: 14),

          _buildCatalogCard(
            context,
            width: 175,
          ),
        ],
      ),
    );
  }

  Widget _buildOldListCard(
      BuildContext context, {
        required double width,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 175,
      height: 138,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outlineVariant,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(
                alpha: 0.08,
              ),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 4; i++) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: i == 1 ? 0.70 : 0.90,
                  child: Container(
                    height: 7,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
              if (i != 3)
                const SizedBox(height: 7),
            ],

            const SizedBox(height: 8),

            Text(
              'OLD LIST',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiCircle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(
              alpha: 0.28,
            ),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            color: colorScheme.onPrimary,
          ),
          const SizedBox(height: 4),
          Text(
            'AI',
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogCard(
      BuildContext context, {
        required double width,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 175,
      height: 126,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outlineVariant,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(
                alpha: 0.08,
              ),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < 3; i++) ...[
              SizedBox(
                height: 23,
                child: Row(
                  children: [
                    Container(
                      width: 23,
                      height: 23,
                      decoration: BoxDecoration(
                        color: i.isEven
                            ? colorScheme.primaryContainer
                            : colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),

                    const SizedBox(width: 6),

                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),

                    const SizedBox(width: 5),

                    Text(
                      '₹—',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              if (i != 2)
                const SizedBox(height: 5),
            ],

            const SizedBox(height: 6),

            Text(
              'DIGITAL CATALOG',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 9,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SLIDE 3
  // FIXED BUSINESS CARDS
  // ============================================================

  Widget _buildBusinessTypeGrid(BuildContext context) {
    const types = <(IconData, String)>[
      (
      Icons.restaurant_menu_outlined,
      'Food',
      ),
      (
      Icons.storefront_outlined,
      'Retail',
      ),
      (
      Icons.shopping_bag_outlined,
      'E-commerce',
      ),
      (
      Icons.work_outline_rounded,
      'Services',
      ),
      (
      Icons.person_outline_rounded,
      'Personal Brand',
      ),
      (
      Icons.apps_outlined,
      'Other',
      ),
    ];

    return SizedBox(
      width: 460,
      height: 260,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 14,
        runSpacing: 14,
        children: types.map((type) {
          return _buildBusinessTypeCard(
            context,
            icon: type.$1,
            label: type.$2,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBusinessTypeCard(
      BuildContext context, {
        required IconData icon,
        required String label,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 223,
      height: 76,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.outlineVariant,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(
                alpha: 0.08,
              ),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 22,
                color: colorScheme.onPrimary,
              ),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SLIDE 4
  //
  //             LOGO
  //            /    \
  //           ↓      ↓
  //   1. BUSINESS   2. PAY
  // ============================================================

  Widget _buildScanViewPay(BuildContext context) {
    return SizedBox(
      width: 500,
      height: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLogoImage(
            size: 64,
          ),

          const SizedBox(height: 4),

          _buildBranchLine(context),

          const SizedBox(height: 4),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepCard(
                context,
                number: '1',
                label: 'Business View',
                icon: Icons.storefront_outlined,
                child: _buildPhoneMockup(
                  context,
                  compact: true,
                ),
              ),

              const SizedBox(width: 20),

              _buildStepCard(
                context,
                number: '2',
                label: 'Pay',
                icon: Icons.payments_outlined,
                child: _buildPaymentMockup(
                  context,
                  compact: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBranchLine(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 300,
      height: 23,
      child: CustomPaint(
        painter: _BranchPainter(
          color: colorScheme.primary.withValues(
            alpha: 0.55,
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(
      BuildContext context, {
        required String number,
        required String label,
        required IconData icon,
        required Widget child,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 210,
      height: 205,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 27,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    number,
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                Icon(
                  icon,
                  size: 16,
                  color: colorScheme.primary,
                ),

                const SizedBox(width: 5),

                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 5),

          // The visual itself is fixed and centered.
          SizedBox(
            height: 148,
            child: Center(
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneMockup(
      BuildContext context, {
        required bool compact,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    const double width = 108;
    const double height = 148;

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: colorScheme.onSurface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(
                alpha: 0.20,
              ),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(17),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 39,
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 6,
                ),
                color: colorScheme.primary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Business',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Digital page',
                      style: TextStyle(
                        color: colorScheme.onPrimary.withValues(
                          alpha: 0.78,
                        ),
                        fontSize: 6,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(5),
                child: Wrap(
                  spacing: 3,
                  children: const [
                    _MiniChip('All'),
                    _MiniChip('Popular'),
                  ],
                ),
              ),

              const _PhoneItem(
                title: 'Signature',
                price: '₹249',
                tag: 'Best Seller',
                compact: true,
              ),

              const _PhoneItem(
                title: 'Recommended',
                price: '₹399',
                tag: 'Recommended',
                compact: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMockup(
      BuildContext context, {
        required bool compact,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 108,
      height: 148,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outlineVariant,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(
                alpha: 0.10,
              ),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.check_rounded,
                color: colorScheme.onTertiaryContainer,
                size: 20,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              '₹249',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              'Payment confirmed',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 7,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  Widget _buildNavigation(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = _currentPage == _pageCount - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        8,
        18,
        14,
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous',
            onPressed: _currentPage == 0
                ? null
                : _previous,
            icon: const Icon(
              Icons.arrow_back_rounded,
            ),
          ),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pageCount,
                    (index) {
                  final active = index == _currentPage;

                  return AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 260,
                    ),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
                    width: active ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(
                        999,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          FilledButton.icon(
            onPressed: _next,
            icon: Icon(
              isLast
                  ? Icons.arrow_forward_rounded
                  : Icons.arrow_forward_ios_rounded,
              size: 18,
            ),
            label: Text(
              isLast
                  ? 'Get Started'
                  : 'Next',
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// BRANCH PAINTER
// ============================================================================

class _BranchPainter extends CustomPainter {
  const _BranchPainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;

    final leftX = 48.0;
    final rightX = size.width - 48;

    final startY = 0.0;
    final middleY = 12.0;
    final endY = size.height;

    final path = Path()
      ..moveTo(
        centerX,
        startY,
      )
      ..lineTo(
        centerX,
        middleY,
      )
      ..lineTo(
        leftX,
        middleY,
      )
      ..lineTo(
        leftX,
        endY - 5,
      )
      ..moveTo(
        centerX,
        middleY,
      )
      ..lineTo(
        rightX,
        middleY,
      )
      ..lineTo(
        rightX,
        endY - 5,
      );

    canvas.drawPath(
      path,
      paint,
    );

    _drawArrow(
      canvas,
      Offset(
        leftX,
        endY - 1,
      ),
      paint,
    );

    _drawArrow(
      canvas,
      Offset(
        rightX,
        endY - 1,
      ),
      paint,
    );
  }

  void _drawArrow(
      Canvas canvas,
      Offset tip,
      Paint paint,
      ) {
    const arrowSize = 5.0;

    final path = Path()
      ..moveTo(
        tip.dx - arrowSize,
        tip.dy - arrowSize,
      )
      ..lineTo(
        tip.dx,
        tip.dy,
      )
      ..lineTo(
        tip.dx + arrowSize,
        tip.dy - arrowSize,
      );

    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(
      covariant _BranchPainter oldDelegate,
      ) {
    return oldDelegate.color != color;
  }
}

// ============================================================================
// SMALL PHONE COMPONENTS
// ============================================================================

class _MiniChip extends StatelessWidget {
  const _MiniChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PhoneItem extends StatelessWidget {
  const _PhoneItem({
    required this.title,
    required this.price,
    required this.compact,
    this.tag,
  });

  final String title;
  final String price;
  final String? tag;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 10,
        vertical: compact ? 3 : 5,
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 18 : 24,
            height: compact ? 18 : 24,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
          ),

          SizedBox(
            width: compact ? 5 : 7,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 7 : 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                if (tag != null)
                  Text(
                    tag!,
                    style: TextStyle(
                      fontSize: compact ? 5.5 : 7,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),

          Text(
            price,
            style: TextStyle(
              fontSize: compact ? 7 : 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}