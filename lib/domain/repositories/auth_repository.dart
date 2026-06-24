import '../entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  Future<AppUser> login(String email, String password);
  Future<AppUser> register(String email, String password, String name);
  Future<void> logout();
}