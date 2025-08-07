import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:earthquake_mapp/core/utils/logger_helper.dart';
import 'package:earthquake_mapp/core/utils/storage/user_local_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

/// Auth işlemlerinin durumunu tutan sınıf
class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;

  AuthState({this.isLoading = false, this.user, this.error});

  AuthState copyWith({bool? isLoading, User? user, String? error}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

/// ViewModel
class AuthViewModel extends StateNotifier<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final StreamSubscription<User?> _authSubscription;

  AuthViewModel() : super(AuthState()) {
    // Oturum durumunu dinle
    _authSubscription = _auth.authStateChanges().listen((user) {
      state = state.copyWith(user: user);
    });
  }
  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  Logger logger = Logger();

  /// Giriş yap
  Future<void> signIn(String email, String password) async {
    LoggerHelper.info('Auth', 'signIn başlatıldı: $email');
    logger.i('Auth : signIn başlatıldı: $email');
    state = state.copyWith(isLoading: true, error: null);

    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      LoggerHelper.debug('Auth', 'Giriş başarılı: ${result.user?.email}');
      state = state.copyWith(isLoading: false, user: result.user, error: null);
      await UserLocalStorage.saveUser(
        email: result.user?.email ?? '',
        uid: result.user?.uid ?? '',
      );
    } on FirebaseAuthException catch (e, st) {
      LoggerHelper.err('Auth', 'FirebaseAuthException: ${e.message}', e, st);
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e, st) {
      LoggerHelper.err('Auth', 'Bilinmeyen hata: $e', e, st);
      state = state.copyWith(isLoading: false, error: "Bilinmeyen hata");
    }
  }

  /// Kayıt ol
  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
  }) async {
    LoggerHelper.info('Auth', 'signUp başlatıldı: $email');
    state = state.copyWith(isLoading: true, error: null);
    User? user;
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      user = result.user;

      if (user == null) {
        LoggerHelper.warning('Auth', 'Kullanıcı oluşturulamadı');
        state = state.copyWith(
          isLoading: false,
          error: "Kullanıcı oluşturulamadı",
        );
        return;
      }

      // Firestore'a kaydet
      await _firestore.collection('users').doc(user.uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'birthDate': birthDate.toIso8601String(),
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      LoggerHelper.info('Auth', 'Firestore kaydı başarılı: ${user.uid}');

      state = state.copyWith(isLoading: false, user: user, error: null);
    } catch (e, st) {
      LoggerHelper.err('Auth', 'signUp hatası: $e', e, st);

      // Eğer Firestore kaydı sırasında hata olduysa Firebase user'ı sil
      if (user != null) {
        try {
          await user.delete();
          LoggerHelper.info('Auth', 'Hatalı kullanıcı silindi: ${user.uid}');
        } catch (deleteError, deleteStack) {
          LoggerHelper.err(
            'Auth',
            'Kullanıcı silinemedi: $deleteError',
            deleteError,
            deleteStack,
          );
        }
      }

      // Hata mesajını ayarla
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Çıkış yap
  Future<void> signOut() async {
    LoggerHelper.info('Auth', 'signOut başlatıldı');
    await _auth.signOut();
    state = AuthState();
    LoggerHelper.info('Auth', 'signOut tamamlandı');
  }
}
