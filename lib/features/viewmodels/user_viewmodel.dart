import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:earthquake_mapp/data/models/user_model/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserViewModel extends StateNotifier<List<UserModel>> {
  UserViewModel() : super([]);

  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('users');

  // Read (Get) tek kullanıcı
  Stream<UserModel?> getUserStreamById(String id) {
    return _usersCollection.doc(id).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromJson({
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        });
      }
      return null;
    });
  }

  // Update kullanıcı

  Future<void> updateUser(UserModel updatedUser) async {
    // Firestore'da güncelle
    await _usersCollection.doc(updatedUser.id).set(updatedUser.toJson());

    // Eğer state içinde kullanıcı listesi tutuyorsan, güncelleyip notify et
    final index = state.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      final newList = [...state];
      newList[index] = updatedUser;
      state = newList;
    } else {
      // Yoksa listeye ekle
      state = [...state, updatedUser];
    }
  }
}
