import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String id;
  final String carId;
  final String carBrand;
  final String carModel;
  final String userId;
  final String userName;
  final DateTime bookingDate;
  final String status;
  
  BookingModel({
    required this.id,
    required this.carId,
    required this.carBrand,
    required this.carModel,
    required this.userId,
    required this.userName,
    required this.bookingDate,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'carId': carId,
      'carBrand': carBrand,
      'carModel': carModel,
      'userId': userId,
      'userName': userName,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'status': status,
    };
  }

  factory BookingModel.fromMap(String id, Map<String, dynamic> map) {
    return BookingModel(
      id: id,
      carId: map['carId'] ?? '',
      carBrand: map['carBrand'] ?? '',
      carModel: map['carModel'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      bookingDate: (map['bookingDate'] as Timestamp).toDate(),
      status: map['status'] ?? 'reserved',
    );
  }
}
