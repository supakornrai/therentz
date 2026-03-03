import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:the_rentz/models/message_model.dart';

class ChatService extends ChangeNotifier {
  //get instance of firestore & auth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //get user stream
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('Users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        user['uid'] = doc.id;
        return user;
      }).toList();
    });
  }

  //get user stream except block user
  Stream<List<Map<String, dynamic>>> getUsersStreamExcludingBlocked() {
    final currentUser = _auth.currentUser;

    return _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
          final blockedUserID = snapshot.docs.map((doc) => doc.id).toList();

          final userSnapshot = await _firestore.collection('Users').get();

          return userSnapshot.docs
              .where(
                (doc) =>
                    doc.data()['Email'] != currentUser.email &&
                    !blockedUserID.contains(doc.id),
              )
              .map((doc) => doc.data())
              .toList();
        });
  }

  //sent message
  Future<void> sendMessage(String receiverID, message) async {
    //get current user
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    //create new message
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("message")
        .add(newMessage.toMap());
  }

  //get message
  Stream<QuerySnapshot> getMessage(String userID, otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("message")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  //report
  Future<void> reportUser(String userID) async {
    final currentUser = _auth.currentUser;
    final report = {
      'reportedBy': currentUser!.uid,
      'ownerId': userID,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('Reports').add(report);
  }

  //block user
  Future<void> blockUser(String userID) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(userID)
        .set({});

    notifyListeners();
  }

  //unblock user
  Future<void> unBlockUser(String blockedUserID) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(blockedUserID)
        .delete();
  }

  //get block user stream
  Stream<List<Map<String, dynamic>>> getblockedUserStream(String userID) {
    return _firestore
        .collection("Users")
        .doc(userID)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
          final blockedUsersID = snapshot.docs.map((doc) => doc.id).toList();

          final userDocs = await Future.wait(
            blockedUsersID.map(
              (id) => _firestore.collection('Users').doc(id).get(),
            ),
          );
          return userDocs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['uid'] = doc.id; // Add this line to include the UID
            return data;
          }).toList();
        });
  }
}
