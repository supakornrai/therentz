import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_rentz/enum.dart';

class UserModel {
  final String? id;
  String userName;
  String firstName;
  String lastName;
  String email;
  String phoneNumber;
  String profileImage;
  AppRole role;
  int? age;           
  String? gender;
  DateTime? createAt;
  DateTime? updateAt;
  bool isSuspended;

  UserModel({
    this.id,
    required this.email,
    this.userName = '',
    this.firstName = '',
    this.lastName = '',
    this.phoneNumber = '',
    this.profileImage = '',
    this.role = AppRole.user,
    this.age,
    this.gender,
    this.createAt,
    this.updateAt,
    this.isSuspended = false,
  });

  //convert model to json
  Map<String, dynamic> toJson() {
  return {
    'Id': id,
    'Username' : userName,
    'Firstname' : firstName,
    'Lastname' : lastName,
    'Email' : email,
    'Phone number' : phoneNumber,
    'Profile Image' : profileImage,
    'Role' : role.name,
    'Age': age,        
      'Gender': gender,
    'Create At' : createAt != null ? Timestamp.fromDate(createAt!) : FieldValue.serverTimestamp(),
    'Update at' : updateAt != null ? Timestamp.fromDate(updateAt!) : FieldValue.serverTimestamp(),
    'isSuspended': isSuspended,
  };
  }
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      userName: map['Username'] ?? '',
      firstName: map['Firstname'] ?? '',
      lastName: map['Lastname'] ?? '',
      email: map['Email'] ?? '',
      phoneNumber: map['Phone number'] ?? '',
      profileImage: map['Profile Image'] ?? '',
      role: AppRole.values.firstWhere(
        (e) => e.name == map['Role'],
        orElse: () => AppRole.user,
      ),
      age: map['Age'],    
      gender: map['Gender'],
      createAt: (map['Create At'] as Timestamp?)?.toDate(),
      updateAt: (map['Update at'] as Timestamp?)?.toDate(),
      isSuspended: map['isSuspended'] ?? false,
    );
  }

  
}