import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // REGISTER
  Future<UserCredential> register({
    required String email,
    required String password,
    required String username,
  }) async {

    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    // สร้าง user document พร้อม username
    await _firestore.collection('users').doc(cred.user!.uid).set({
      'email': email.trim(),
      'username': username.trim(),
      'role': 'customer',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return cred;
  }

  // LOGIN (ไม่ต้องมี username)
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {

    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    return cred;
  }

  // GOOGLE SIGN IN
  Future<UserCredential?> signInWithGoogle() async {

    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    if (gUser == null) return null;

    final GoogleSignInAuthentication gAuth =
        await gUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    final userCredential =
        await _auth.signInWithCredential(credential);

    // ถ้าไม่มี document ค่อยสร้าง
    final doc = await _firestore
        .collection('users')
        .doc(userCredential.user!.uid)
        .get();

    if (!doc.exists) {
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': userCredential.user!.email,
        'username':
            userCredential.user!.displayName ?? 'No Name',
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return userCredential;
  }

  Future<void> logout() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}
