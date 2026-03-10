import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_rentz/models/booking_model.dart';
import 'package:the_rentz/services/booking_service.dart';
import 'package:the_rentz/pages/staff/staff_add_car_page.dart';

class CarDetailPage extends StatefulWidget {
  final Map<String, dynamic> car;
  final bool isStaff;

  CarDetailPage({super.key, required this.car, this.isStaff = false});

  @override
  State<CarDetailPage> createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<CarDetailPage> {
  final BookingService _bookingService = BookingService();

  void _showBookingDialog() async {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: selectedTime,
      );

      if (pickedTime != null) {
        DateTime finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        _confirmBooking(finalDateTime);
      }
    }
  }

  void _confirmBooking(DateTime bookingDate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text("Confirm Booking"),
        content: Text(
          "Book ${widget.car["Brand"]} ${widget.car["Model"]} for ${DateFormat('dd MMM yyyy HH:mm').format(bookingDate)}?",
          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                final userDoc = await FirebaseFirestore.instance
                    .collection("Users")
                    .doc(user.uid)
                    .get();
                String userName = userDoc.data()?['Username'] ?? 'User';

                BookingModel newBooking = BookingModel(
                  id: '',
                  carId: widget.car["id"],
                  carBrand: widget.car["Brand"] ?? '',
                  carModel: widget.car["Model"] ?? '',
                  userId: user.uid,
                  userName: userName,
                  bookingDate: bookingDate,
                  status: 'reserved',
                );

                await _bookingService.createBooking(newBooking);

                if (mounted) {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text("Booking Successful!")),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text("Confirm"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String image = "";

    if (widget.car["Images"] != null && widget.car["Images"].isNotEmpty) {
      image = widget.car["Images"][0];
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            actions: widget.isStaff
                ? [
                    IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StaffAddCarPage(car: widget.car),
                          ),
                        ).then((_) {
                          // Refresh data if needed, or rely on Firestore snapshots elsewhere
                          setState(() {});
                        });
                      },
                    ),
                    SizedBox(width: 8),
                  ]
                : null,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  image.isNotEmpty
                      ? Hero(
                          tag: widget.car["id"],
                          child: Image.network(image, fit: BoxFit.cover),
                        )
                      : Container(color: Theme.of(context).colorScheme.secondary),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 30,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.car["Brand"] ?? "",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.car["Model"] ?? "",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Price",
                              style: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                            Text(
                              "฿${widget.car["Price"]}",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: ((widget.car["Status"]?.toString().toLowerCase() == "available" ||
                                        widget.car["Status"] == null)
                                    ? Colors.green
                                    : Theme.of(context).colorScheme.primary)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.car["Status"]?.toString().toUpperCase() ?? "AVAILABLE",
                            style: TextStyle(
                              color: (widget.car["Status"]?.toString().toLowerCase() == "available" ||
                                      widget.car["Status"] == null)
                                  ? Colors.green
                                  : Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    Text(
                      "Specifications",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        _buildSpecCard(context, Icons.calendar_today_rounded, "Year", widget.car["Year"].toString()),
                        SizedBox(width: 12),
                        _buildSpecCard(context, Icons.speed_rounded, "Mileage", "${widget.car["Mileage"]} km"),
                      ],
                    ),
                    SizedBox(height: 32),
                    Text(
                      "Description",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    Text(
                      widget.car["Description"] ?? "No description available for this vehicle.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.7),
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
      bottomSheet: widget.isStaff
          ? null
          : Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(top: BorderSide(color: Theme.of(context).colorScheme.tertiary, width: 0.5)),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                  shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                ),
                onPressed: _showBookingDialog,
                child: Text("Book Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
    );
  }

  Widget _buildSpecCard(BuildContext context, IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).colorScheme.tertiary, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
            SizedBox(height: 12),
            Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
            SizedBox(height: 4),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis, maxLines: 1),
          ],
        ),
      ),
    );
  }
}
