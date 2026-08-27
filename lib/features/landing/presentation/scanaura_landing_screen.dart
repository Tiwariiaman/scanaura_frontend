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
    if (_currentPage == 0) return;
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
                  setState(() => _currentPage = page);
                },
                itemBuilder: (context, index) =>
                    _buildPage(context, index),
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
    final colorScheme = Theme.of(context).colorScheme;

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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

  Widget _buildPage3(BuildContext context) {
    return _buildCenteredSlide(
      context,
      title: 'Built for every business.',
      subtitle: 'One platform. Any business.',
      visual: _buildBusinessTypeGrid(context),
    );
  }

  Widget _buildPage4(BuildContext context) {
    return _buildCenteredSlide(
      context,
      title: 'Scan. View. Pay.',
      subtitle: 'One QR. One digital destination.',
      visual: _buildScanViewPay(context),
    );
  }

  Widget _buildPage5(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _buildCenteredSlide(
      context,
      title: 'Go digital from ₹99/month.',
      subtitle: 'Start simple. Grow with ScanAura.',
      visual: _buildWhiteCard(
        context,
        maxWidth: 390,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
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
  // Headline + tagline first, then white elevated visual card.
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
        horizontal: 20,
        vertical: 8,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact =
              constraints.maxHeight < 620;

          final titleSize =
          constraints.maxWidth < 380
              ? 28.0
              : 34.0;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1000,
              ),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal:
                  constraints.maxWidth < 500
                      ? 18
                      : 28,
                  vertical:
                  compact ? 14 : 22,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius:
                  BorderRadius.circular(28),
                  border: Border.all(
                    color:
                    colorScheme.outlineVariant,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow
                          .withValues(
                        alpha: 0.10,
                      ),
                      blurRadius: 28,
                      offset:
                      const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.start,
                  crossAxisAlignment:
                  CrossAxisAlignment.center,
                  children: [
                    // -----------------------------------------------
                    // PILL
                    // -----------------------------------------------

                    if (pill != null) ...[
                      _buildPill(
                        context,
                        pill,
                        usePrimary:
                        pillUsesPrimary,
                      ),
                      SizedBox(
                        height:
                        compact ? 7 : 10,
                      ),
                    ],

                    // -----------------------------------------------
                    // HEADLINE
                    // -----------------------------------------------

                    Text(
                      title,
                      textAlign:
                      TextAlign.center,
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style: theme
                          .textTheme
                          .displaySmall
                          ?.copyWith(
                        fontSize:
                        titleSize,
                        fontWeight:
                        FontWeight.w800,
                        letterSpacing:
                        -1.0,
                        height: 1.02,
                      ),
                    ),

                    SizedBox(
                      height:
                      compact ? 5 : 8,
                    ),

                    // -----------------------------------------------
                    // TAGLINE
                    // -----------------------------------------------

                    Text(
                      subtitle,
                      textAlign:
                      TextAlign.center,
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style: theme
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        color: colorScheme
                            .onSurfaceVariant,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),

                    // -----------------------------------------------
                    // HINT
                    // -----------------------------------------------

                    if (hint != null) ...[
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        hint,
                        textAlign:
                        TextAlign.center,
                        maxLines: 1,
                        overflow:
                        TextOverflow.ellipsis,
                        style: theme
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color: colorScheme
                              .onSurfaceVariant,
                        ),
                      ),
                    ],

                    SizedBox(
                      height:
                      compact ? 8 : 12,
                    ),

                    // -----------------------------------------------
                    // VISUAL CONTENT
                    // -----------------------------------------------

                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints:
                          const BoxConstraints(
                            maxWidth: 900,
                          ),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: visual,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWhiteCard(
      BuildContext context, {
        required Widget child,
        double? maxWidth,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? 900),
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
              color: colorScheme.shadow.withValues(alpha: 0.10),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
  // SLIDE 1: BUSINESS -> LOGO -> CUSTOMER
  // ============================================================

  Widget _buildBusinessFlow(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildFlowNode(
            context,
            icon: Icons.storefront_outlined,
            label: 'Business',
          ),
          _buildHorizontalConnector(context),
          _buildLogoBlock(context, size: 86),
          _buildHorizontalConnector(context),
          _buildFlowNode(
            context,
            icon: Icons.smartphone_outlined,
            label: 'Customer',
          ),
        ],
      ),
    );
  }

  Widget _buildFlowNode(
      BuildContext context, {
        required IconData icon,
        required String label,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 18,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoBlock(
      BuildContext context, {
        required double size,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.rectangle,
      ),
      alignment: Alignment.center,
      child: Image.asset(
        'assets/images/scanaura_logo_white.png',
        width: size * 0.92,
        height: size * 0.92,
        fit: BoxFit.fill,
      ),
    );
  }

  Widget _buildHorizontalConnector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 32,
      height: 2,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // ============================================================
  // SLIDE 2: AI IMPORT
  // ============================================================

  Widget _buildAiFlow(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = width < 600 ? 125.0 : 170.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildOldListCard(context, width: cardWidth),
        _buildHorizontalConnector(context),
        _buildAiCircle(context),
        _buildHorizontalConnector(context),
        _buildCatalogCard(context, width: cardWidth),
      ],
    );
  }

  Widget _buildOldListCard(
      BuildContext context, {
        required double width,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < 4; i++) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: i == 1 ? 0.70 : 0.90,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            if (i != 3) const SizedBox(height: 9),
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
    );
  }

  Widget _buildAiCircle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.28),
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

    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < 3; i++) ...[
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: i.isEven
                        ? colorScheme.primaryContainer
                        : colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  '₹—',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            if (i != 2) const SizedBox(height: 9),
          ],
          const SizedBox(height: 8),
          Text(
            'DIGITAL CATALOG',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SLIDE 3: TWO CARDS PER ROW
  // ============================================================

  Widget _buildBusinessTypeGrid(BuildContext context) {
    const types = <(IconData, String)>[
      (Icons.restaurant_menu_outlined, 'Food'),
      (Icons.storefront_outlined, 'Retail'),
      (Icons.shopping_bag_outlined, 'E-commerce'),
      (Icons.work_outline_rounded, 'Services'),
      (Icons.person_outline_rounded, 'Personal Brand'),
      (Icons.apps_outlined, 'Other'),
    ];

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final spacing = 12.0;
          final cardWidth =
              (constraints.maxWidth - spacing) / 2;

          return Wrap(
            alignment: WrapAlignment.center,
            spacing: spacing,
            runSpacing: spacing,
            children: types.map((type) {
              return SizedBox(
                width: cardWidth,
                child: _buildBusinessTypeCard(
                  context,
                  icon: type.$1,
                  label: type.$2,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildBusinessTypeCard(
      BuildContext context, {
        required IconData icon,
        required String label,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 90),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 23,
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 10),
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
    );
  }

  // ============================================================
  // SLIDE 4: SCAN -> VIEW -> PAY
  // ============================================================

  Widget _buildScanViewPay(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        final visualSize = compact ? 82.0 : 112.0;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStep(
              context,
              label: 'SCAN',
              child: _buildLogoScanCard(
                context,
                size: visualSize,
              ),
            ),
            _buildHorizontalConnector(context),
            _buildStep(
              context,
              label: 'VIEW',
              child: _buildPhoneMockup(
                context,
                compact: compact,
              ),
            ),
            _buildHorizontalConnector(context),
            _buildStep(
              context,
              label: 'PAY',
              child: _buildPaymentMockup(
                context,
                compact: compact,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLogoScanCard(
      BuildContext context, {
        required double size,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.24),
              blurRadius: 26,
              spreadRadius: 2,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Image.asset(
          'assets/images/scanaura_logo_white.png',
          width: 22,
          height: 22,
          fit: BoxFit.contain,
        )
    );
  }

  Widget _buildStep(
      BuildContext context, {
        required String label,
        required Widget child,
      }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildPhoneMockup(
      BuildContext context, {
        required bool compact,
      }) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = compact ? 112.0 : 156.0;
    final height = compact ? 198.0 : 270.0;

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: colorScheme.onSurface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.22),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(11),
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
                      fontSize: compact ? 9 : 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Digital page',
                    style: TextStyle(
                      color: colorScheme.onPrimary.withValues(alpha: 0.78),
                      fontSize: compact ? 7 : 10,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(9),
              child: Wrap(
                spacing: 4,
                children: const [
                  _MiniChip('All'),
                  _MiniChip('Popular'),
                ],
              ),
            ),
            _PhoneItem(
              title: 'Signature Item',
              price: '₹249',
              tag: 'Best Seller',
              compact: compact,
            ),
            _PhoneItem(
              title: 'Recommended',
              price: '₹399',
              tag: 'Recommended',
              compact: compact,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMockup(
      BuildContext context, {
        required bool compact,
      }) {
    final colorScheme = Theme.of(context).colorScheme;
    final width = compact ? 108.0 : 148.0;

    return Container(
      width: width,
      padding: EdgeInsets.all(compact ? 14 : 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.10),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 42 : 50,
            height: compact ? 42 : 50,
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.check_rounded,
              color: colorScheme.onTertiaryContainer,
              size: compact ? 22 : 28,
            ),
          ),
          SizedBox(height: compact ? 9 : 14),
          Text(
            '₹249',
            style: TextStyle(
              fontSize: compact ? 19 : 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Payment confirmed',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: compact ? 8 : null,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous',
            onPressed: _currentPage == 0 ? null : _previous,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pageCount,
                    (index) {
                  final active = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
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
              isLast ? 'Get Started' : 'Next',
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// SMALL PHONE COMPONENTS
// ================================================================

class _MiniChip extends StatelessWidget {
  const _MiniChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
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
          SizedBox(width: compact ? 5 : 7),
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
