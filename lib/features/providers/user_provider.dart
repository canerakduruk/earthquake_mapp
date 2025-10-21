import 'package:earthquake_mapp/data/models/user_model/user_model.dart';
import 'package:earthquake_mapp/features/viewmodels/user_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userViewModelProvider =
    StateNotifierProvider<UserViewModel, List<UserModel>>(
      (ref) => UserViewModel(),
    );

final currentUserStreamProvider = StreamProvider<UserModel?>((ref) {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  if (currentUserId == null) return Stream.value(null);

  final userViewModel = ref.read(userViewModelProvider.notifier);
  return userViewModel.getUserStreamById(currentUserId);
});
