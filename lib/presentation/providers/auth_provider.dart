import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/realtime_api_client.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

final realtimeApiClientProvider = Provider<RealtimeApiClient>((ref) {
  return RealtimeApiClient(databaseUrl: AppConstants.databaseUrl);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(apiClient: ref.watch(realtimeApiClientProvider));
});

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(authRepositoryProvider).login(email, password);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
      state = const AsyncValue.loading();
      try {
        await ref.read(authRepositoryProvider).register(email, password, name);
        
        // Tambahkan baris ini: Paksa logout setelah registrasi berhasil
        await ref.read(authRepositoryProvider).logout(); 
        
        state = const AsyncValue.data(null);
        return true;
      } catch (e, st) {
        state = AsyncValue.error(e, st);
        return false;
      }
    }

  Future<void> logout() => ref.read(authRepositoryProvider).logout();
}

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);