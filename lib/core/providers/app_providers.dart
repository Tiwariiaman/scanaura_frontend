import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/admin/data/admin_repository.dart';
import '../../features/admin/data/admin_subscription_repository.dart';
import '../../features/business/data/business_repository.dart';
import '../../features/menu/data/menu_repository.dart';
import '../../features/public_menu/data/public_repository.dart';
import '../../features/qr/data/qr_repository.dart';
import '../../features/subscription/data/subscription_repository.dart';
import '../network/api_client.dart';
import '../network/image_upload_service.dart';
import '../storage/secure_storage_service.dart';
import '../../features/auth/data/auth_repository.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.read(secureStorageProvider);

  return ApiClient(
    secureStorageService: secureStorage,
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);

  return AuthRepository(
    apiClient: apiClient,
  );
});

final businessRepositoryProvider =
Provider<BusinessRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);

  return BusinessRepository(
    apiClient: apiClient,
  );
});

final subscriptionRepositoryProvider =
Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository(
    apiClient: ref.read(apiClientProvider),
  );
});

final imageUploadServiceProvider =
Provider<ImageUploadService>((ref) {
  return ImageUploadService(
    apiClient: ref.read(apiClientProvider),
  );
});

final qrRepositoryProvider = Provider<QrRepository>((ref) {
  return QrRepository(
    apiClient: ref.read(apiClientProvider),
  );
});

final menuRepositoryProvider =
Provider<MenuRepository>((ref) {
  return MenuRepository(
    apiClient: ref.read(apiClientProvider),
  );
});

final publicRepositoryProvider =
Provider<PublicRepository>((ref) {
  return PublicRepository(
    apiClient: ref.read(apiClientProvider),
  );
});

final adminRepositoryProvider =
Provider<AdminRepository>((ref) {
  return AdminRepository(
    apiClient: ref.read(apiClientProvider),
  );
});

final adminSubscriptionRepositoryProvider =
Provider<AdminSubscriptionRepository>((ref) {
  return AdminSubscriptionRepository(
    apiClient: ref.read(apiClientProvider),
  );
});
