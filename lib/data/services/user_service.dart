import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(String uid, String name) async {
    await _firestore.collection('users').doc(uid).set({'name': name});
  }

  Future<void> updateUser(String uid, String name) async {
    await _firestore.collection('users').doc(uid).update({'name': name});
  }

  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }
}
