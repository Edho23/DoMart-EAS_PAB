import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../core/network/realtime_api_client.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final fb.FirebaseAuth _auth;
  final RealtimeApiClient _apiClient;

  AuthRepositoryImpl({fb.FirebaseAuth? firebaseAuth, required RealtimeApiClient apiClient})
      : _auth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _apiClient = apiClient;

  @override
  Stream<AppUser?> get authStateChanges => _auth.authStateChanges().asyncMap((user) async {
        if (user == null) return null;
        try {
          final token = await user.getIdToken();
          final data = await _apiClient.get('users/${user.uid}', idToken: token);
          final role = (data is Map && data['role'] != null) ? data['role'] as String : 'customer';
          return AppUser(uid: user.uid, email: user.email ?? '', name: user.displayName, role: role);
        } catch (_) {
          return AppUser(uid: user.uid, email: user.email ?? '', name: user.displayName);
        }
      });

  @override
  Future<AppUser> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return AppUser(uid: cred.user!.uid, email: cred.user!.email ?? '', name: cred.user!.displayName);
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    }
  }

  @override
  Future<AppUser> register(String email, String password, String name) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await cred.user?.updateDisplayName(name);

      final token = await cred.user!.getIdToken();
      await _apiClient.put('users/${cred.user!.uid}', {
        'name': name,
        'email': email,
        'role': 'customer',
        'createdAt': DateTime.now().toIso8601String(),
      }, idToken: token);

      return AppUser(uid: cred.user!.uid, email: email, name: name);
    } on fb.FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    }
  }

  @override
  Future<void> logout() => _auth.signOut();

  String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email sudah terdaftar';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter)';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah';
      default:
        return 'Terjadi kesalahan, coba lagi';
    }
  }
}