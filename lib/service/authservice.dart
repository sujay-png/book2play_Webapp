
import 'package:booktoplay_webapp/models/appuser.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AppUser? _userFromFirebaseUser(User? user) {
    return user != null 
      ? AppUser(uid: user.uid, email: user.email ?? 'anonymous') 
      : null;
  }
   Stream<AppUser?> get user => _auth.authStateChanges().map(_userFromFirebaseUser);

    // Sign In (No Firestore write needed here)
  Future<AppUser?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return _userFromFirebaseUser(result.user);
    } catch (e) {
      print("SignIn Error: $e");
      return null;
    }
  }
}