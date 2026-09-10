class ApiConstants {
  ApiConstants._();

  // ============================================================
  // BASE URL
  // ============================================================

  // Android emulator
  static const String androidBaseUrl =
      'http://10.0.2.2:8080';

  // Chrome / Web
  static const String webBaseUrl =
      'http://localhost:8080';

  // Production
  static const String productionBaseUrl =
      'https://api.scanaura.in';

  // ============================================================
  // AUTHENTICATION
  // ============================================================

  static const String authRegister =
      '/api/v1/auth/register';

  static const String authLogin =
      '/api/v1/auth/login';

  // ============================================================
  // BUSINESS
  // ============================================================

  static const String businessBase =
      '/api/v1/business';

  static const String businessMine =
      '/api/v1/business/me';

  // ============================================================
  // SUBSCRIPTION
  // ============================================================

  static const String subscriptionMy =
      '/api/v1/subscription/my';

  static const String subscriptionRequest =
      '/api/v1/subscription/request';

  static const String subscriptionRequestHistory =
      '/api/v1/subscription/request/history';

  // ============================================================
  // IMAGE
  // ============================================================

  static const String imageUpload =
      '/api/v1/images/upload';

  // ============================================================
  // QR
  // ============================================================

  static const String qrBase =
      '/api/v1/qr';

  static const String qrDigital =
      '$qrBase/digital';

  static const String qrMy =
      '$qrBase/my';

  // ============================================================
  // CATEGORIES
  // ============================================================

  static const String categoryBase =
      '/api/v1/categories';

  static String categoryById(
      String id,
      ) {
    return '$categoryBase/$id';
  }

  static const String categories =
      '/api/v1/categories';

  // ============================================================
  // CATALOG / MENU
  // ============================================================

  static const String catalogBase =
      '/api/v1/catalog';

  static const String catalog =
      catalogBase;

  static String catalogById(
      String id,
      ) {
    return '$catalogBase/$id';
  }

  // ============================================================
  // AI MENU
  // ============================================================

  static const String aiMenuBase =
      '/api/v1/ai/menu';

  static const String aiMenuAnalyze =
      '$aiMenuBase/analyze';

  static const String aiMenuImport =
      '$aiMenuBase/import';

  // ============================================================
  // PUBLIC BUSINESS
  // ============================================================

  static const String publicBase =
      '/api/public';

  static const String publicLanding =
      '$publicBase/q';

  static const String publicMenu =
      '$publicBase/q';

  static const String publicPayment =
      '$publicBase/q';

  // ============================================================
  // ACTIVITY / LOYALTY
  // ============================================================

  static const String activityBase =
      '/api/activity';

  static const String loyaltyBase = '$activityBase/loyalty';

  static const String loyaltySettings =
      '$loyaltyBase/settings';

  static const String loyaltyRewards =
      '$loyaltyBase/rewards';

  static String loyaltyRewardById(String rewardId) =>
      '$loyaltyRewards/$rewardId';

  static const String loyaltyCustomer =
      '$loyaltyBase/customer';

  static const String loyaltyVisitQr =
      '$loyaltyBase/visit/qr';

  static const String loyaltyVisitVerify =
      '$loyaltyBase/visit/verify';

  static const String loyaltyClaim =
      '$loyaltyBase/claim';

  static String loyaltyClaimQr(String claimId) =>
      '$loyaltyClaim/$claimId/qr';

  static const String loyaltyClaimVerify =
      '$loyaltyClaim/verify';
  // ============================================================
  // ADMIN
  // ============================================================

  static const String adminBase =
      '/api/v1/admin';

  static const String adminDashboard =
      '$adminBase/dashboard';

  static const String adminBusinesses =
      '$adminBase/businesses';

  static const String adminBusinessSearch =
      '$adminBusinesses/search';

  static String adminActivateBusiness(
      String businessId,
      ) {
    return '$adminBusinesses/$businessId/activate';
  }

  static String adminDeactivateBusiness(
      String businessId,
      ) {
    return '$adminBusinesses/$businessId/deactivate';
  }

  static const String adminQrInventory =
      '$adminBase/qr/inventory';

  static String adminGenerateQr(
      int count,
      ) {
    return '$adminBase/qr/generate/$count';
  }

  static String adminDeactivateQr(
      String qrCode,
      ) {
    return '$adminBase/qr/deactivate/$qrCode';
  }

  // ============================================================
  // ADMIN SUBSCRIPTION REQUESTS
  // ============================================================

  static const String adminSubscriptionRequests =
      '/api/v1/admin/subscription-requests';

  static const String adminPendingSubscriptions =
      '$adminSubscriptionRequests/pending';

  static String adminApproveSubscription(
      String requestId,
      ) {
    return '$adminSubscriptionRequests/$requestId/approve';
  }

  static String adminRejectSubscription(
      String requestId,
      ) {
    return '$adminSubscriptionRequests/$requestId/reject';
  }

  // ============================================================
  // ADMIN SUBSCRIPTION MANAGEMENT
  // ============================================================

  static const String adminSubscriptionBase =
      '$adminBase/subscriptions';

  static const String adminSubscriptionPlans =
      '$adminSubscriptionBase/plans';

  static String adminGrantSubscription(
      String businessId,
      ) {
    return '$adminBusinesses/$businessId/subscription';
  }
}