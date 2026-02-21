import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // app register
  Future<UserCredential> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    // creat document for keep user infor.
    await _firestore.collection('users').doc(cred.user!.uid).set({
      'email': email.trim(),
      'username': username.trim(),
      'role': 'customer',
      'gender': '-',
      'phone': '-',
      'createdAt': FieldValue.serverTimestamp(),
      'pictureURL': null
    });

    //sent user data back
    return cred;
  }

  //app login
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    //check user in doc
    await _ensureUserDocument(cred.user!);

    return cred;
  }

  //google sign in
  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn(
      clientId:
          '897694489294-223i7b289rtgbeqijiipotv1ivmojp5h.apps.googleusercontent.com',
    ).signIn();

    if (gUser == null) return null;

    final GoogleSignInAuthentication gAuth = await gUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    // ล็อกอินเข้า Firebase ด้วย Google credential
    final userCredential = await _auth.signInWithCredential(credential);

    //make sure that user not null
    await _ensureUserDocument(userCredential.user!);

    return userCredential;
  }

  //for make sure about data's user in doc
  Future<void> _ensureUserDocument(User user) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();

    //google sign in didn't have username and we need to create this first
    //this function will change email to username
    if (!doc.exists) {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'username': user.displayName ?? user.email?.split('@')[0] ?? 'User',
        'role': 'customer',
        'gender': '-',
        'phone': '-',
        'pictureURL' : user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // LOGOUT
  // used this at profile page for logout
  Future<void> logout() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}
