import 'package:earthquake_mapp/data/models/user_model/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserViewModel extends StateNotifier<List<UserModel>> {
  UserViewModel() : super([]);

  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('users');

  // Create (Add) yeni kullanıcı
  Future<void> addUser(UserModel user) async {
    try {
      final docRef = await _usersCollection.add(user.toJson());
      final newUser = UserModel(
        id: docRef.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        birthDate: user.birthDate,
        createdAt: user.createdAt,
      );
      state = [...state, newUser];
    } catch (e) {
      rethrow;
    }
  }

  // Read (Get) tüm kullanıcıları çek
  Future<void> fetchUsers() async {
    try {
      final snapshot = await _usersCollection.get();
      final users = snapshot.docs
          .map(
            (doc) => UserModel.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }),
          )
          .toList();
      state = users;
    } catch (e) {
      rethrow;
    }
  }

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

  // Delete kullanıcı
  Future<void> deleteUser(String id) async {
    try {
      await _usersCollection.doc(id).delete();
      state = state.where((user) => user.id != id).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Kullanıcı adıyla arama (prefix search)
  Future<void> searchUsersByFirstName(String query) async {
    if (query.isEmpty) {
      await fetchUsers();
      return;
    }

    try {
      final snapshot = await _usersCollection
          .where('firstName', isGreaterThanOrEqualTo: query)
          .where('firstName', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      final users = snapshot.docs
          .map(
            (doc) => UserModel.fromJson({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }),
          )
          .toList();

      state = users;
    } catch (e) {
      rethrow;
    }
  }
}
