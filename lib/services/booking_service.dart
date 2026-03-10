import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:the_rentz/models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<void> createBooking(BookingModel booking) async {

    await _firestore.collection("Bookings").add(booking.toMap());
    await _firestore.collection("Cars").doc(booking.carId).update({
      'Status': 'reserved',
    });
  }


  Stream<List<BookingModel>> getUserBookings(String userId) {
    return _firestore
        .collection("Bookings")
        .where("userId", isEqualTo: userId)
        .orderBy("bookingDate", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Stream<List<BookingModel>> getAllBookings() {
    return _firestore
        .collection("Bookings")
        .orderBy("bookingDate", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => BookingModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }


  Future<void> updateBookingStatus(String bookingId, String carId, String status) async {
    await _firestore.collection("Bookings").doc(bookingId).update({
      'status': status,
    });

    if (status == 'cancelled' || status == 'completed') {
       await _firestore.collection("Cars").doc(carId).update({
        'Status': 'available',
      });
    }
  }
}
