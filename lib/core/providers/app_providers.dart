import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/business/data/business_repository.dart';
import '../network/api_client.dart';
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