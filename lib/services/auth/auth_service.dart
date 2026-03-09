import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:the_rentz/enum.dart';
import 'package:the_rentz/models/user_model.dart';

class AuthService {
  // instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  //get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      final userDoc = await _db
          .collection("Users")
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        UserModel newUser = UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          userName: googleUser.displayName ?? '',
          role: AppRole.user,
          createAt: DateTime.now(),
        );
        await _db
            .collection("Users")
            .doc(userCredential.user!.uid)
            .set(newUser.toJson());
      }

      return userCredential;
    } catch (e) {
      throw Exception("Google Sign-In failed: $e");
    }
  }

  //login
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    password,
  ) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await _db
          .collection("Users")
          .doc(userCredential.user!.uid)
          .get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;

        if (data['isSuspended'] == true) {
          await _auth.signOut();
          throw Exception("This account has been suspended by the Admin.");
        }
      }
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //register
  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    password,
  ) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      UserModel newUser = UserModel(
        id: userCredential.user!.uid,
        email: email,
        role: AppRole.user,
        createAt: DateTime.now(),
      );
      await _db
          .collection("Users")
          .doc(userCredential.user!.uid)
          .set(newUser.toJson());
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  //fetch user data
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection("Users").doc(uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return UserModel(
          id: doc.id,
          email: data['Email'] ?? '',
          userName: data['Username'] ?? '',
          firstName: data['Firstname'] ?? '',
          lastName: data['Lastname'] ?? '',
          phoneNumber: data['Phone number'] ?? '',
          role: AppRole.values.firstWhere(
            (e) => e.name == data['Role'],
            orElse: () => AppRole.user,
          ),
        );
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
    return null;
  }

  //for update user info
  Future<void> updateAdditionalProfileInfo({
    required String uid,
    required String username,
    required String firstname,
    required String lastname,
    required int age,
    required AppRole role,
    required String gender,
    required String imageUrl,
  }) async {
    await _db.collection("Users").doc(uid).set({
      'Username': username,
      'Firstname': firstname,
      'Lastname': lastname,
      'Role': role.name,
      'Age': age,
      'Gender': gender,
      'Profile Image': imageUrl,
      'Update at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
