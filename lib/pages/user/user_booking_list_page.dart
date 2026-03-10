import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:the_rentz/models/booking_model.dart';
import 'package:the_rentz/services/booking_service.dart';
import 'package:the_rentz/services/location_service.dart';

class UserBookingListPage extends StatelessWidget {
  UserBookingListPage({super.key});

  final BookingService _bookingService = BookingService();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("My Bookings"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      body: StreamBuilder<List<BookingModel>>(
        stream: _bookingService.getUserBookings(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy_rounded, size: 80, color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                  SizedBox(height: 16),
                  Text("No bookings found", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _buildBookingTile(context, booking);
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingTile(BuildContext context, BookingModel booking) {
    Color statusColor = Colors.orange;
    if (booking.status == 'completed') statusColor = Colors.green;
    if (booking.status == 'cancelled') statusColor = Colors.red;

    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.tertiary, width: 0.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "${booking.carBrand} ${booking.carModel}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  booking.status.toUpperCase(),
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
              SizedBox(width: 8),
              Text(
                DateFormat('dd MMM yyyy').format(booking.bookingDate),
                style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.6), fontSize: 14),
              ),
              SizedBox(width: 16),
              Icon(Icons.access_time_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
              SizedBox(width: 8),
              Text(
                DateFormat('HH:mm').format(booking.bookingDate),
                style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.6), fontSize: 14),
              ),
            ],
          ),
          if (booking.status == 'reserved') ...[
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _bookingService.updateBookingStatus(booking.id, booking.carId, 'cancelled'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withOpacity(0.1),
                foregroundColor: Colors.red,
                elevation: 0,
                minimumSize: Size(double.infinity, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Cancel Booking", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
          if (booking.status == 'reserved' || booking.status == 'completed') ...[
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => LocationService.openDealershipLocation(),
              icon: Icon(Icons.location_on_rounded, size: 18),
              label: Text("View Location", style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                foregroundColor: Theme.of(context).colorScheme.primary,
                elevation: 0,
                minimumSize: Size(double.infinity, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
