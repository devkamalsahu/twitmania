import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitmania/services/database/database_service.dart';

class AuthService {
  // get instance of the current auth status
  final _auth = FirebaseAuth.instance;

  // get curretnt user and uid
  User? getCurrentUser() => _auth.currentUser;
  String getCurrentUserId() => _auth.currentUser!.uid;

  // login -> email & password
  Future<UserCredential> loginEmailPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // register -> email & password
  Future<UserCredential> registerEmailPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // delete account
  Future<void> deleteAccount() async {
    User? user = getCurrentUser();

    if (user != null) {
      // delete the user's data from firestore
      await DatabaseService().deleteUserInfoFromFirebase(user.uid);
      // delete the user's auth record
      await user.delete();
    }
  }
}
