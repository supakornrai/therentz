import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final user = FirebaseAuth.instance.currentUser;

  Future<String> uploadProfileImage(File file) async {
    final storageRef = FirebaseStorage.instance.ref().child(
      "profile_images/${user!.uid}.jpg",
    );

    await storageRef.putFile(file);

    return await storageRef.getDownloadURL();
  }
}
