import 'dart:async';

import 'package:earthquake_mapp/data/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<User?> {
  late AuthService _authService;
  StreamSubscription<User?>? _authSubscription;

  @override
  Future<User?> build() async {
    _authService = ref.watch(authServiceProvider);

    _authSubscription = _authService.authStateChanges().listen((user) {
      state = AsyncValue.data(user);
    });

    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    return _authService.currentUser;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authService.login(email, password);
    } on FirebaseAuthException catch (e, s) {
      state = AsyncValue.error(_handleAuthError(e), s);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> register(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authService.register(email, password);
    } on FirebaseAuthException catch (e, s) {
      state = AsyncValue.error(_handleAuthError(e), s);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _authService.logout();
    } on FirebaseAuthException catch (e, s) {
      state = AsyncValue.error(_handleAuthError(e), s);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Bu e-posta ile kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Yanlış şifre girdiniz.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanımda.';
      case 'weak-password':
        return 'Şifre çok zayıf.';
      case 'invalid-email':
        return 'Geçersiz bir e-posta adresi girdiniz.';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.';
      case 'network-request-failed':
        return 'İnternet bağlantınızı kontrol edin.';
      default:
        return 'Bilinmeyen bir hata oluştu: ${e.code}';
    }
  }
}
