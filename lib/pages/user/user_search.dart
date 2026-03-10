import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_rentz/models/booking_model.dart';
import 'package:the_rentz/pages/chat_page.dart';
import 'package:the_rentz/pages/user/user_booking_list_page.dart';
import 'package:the_rentz/services/booking_service.dart';

enum SortType { none, priceLow, priceHigh, yearNew, yearOld }

class UserSearchPage extends StatefulWidget {
  UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  final String userId = FirebaseAuth.instance.currentUser!.uid;

  SortType sortType = SortType.none;


  void toggleFavorite(String carId, Map<String, dynamic> car) async {
    var ref = FirebaseFirestore.instance
        .collection("Users")
        .doc(userId)
        .collection("favorites")
        .doc(carId);

    var doc = await ref.get();

    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set(car);
    }
  }

  void openDetail(Map<String, dynamic> car) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CarDetailPage(car: car)),
    );
  }

  void openChat(String carId) async {
    try {

      var staffQuery = await FirebaseFirestore.instance
          .collection("Users")
          .where("Role", isEqualTo: "staff")
          .where("assignedCarId", isEqualTo: carId)
          .limit(1)
          .get();

      if (staffQuery.docs.isNotEmpty) {
        var staffData = staffQuery.docs.first.data();
        String staffId = staffQuery.docs.first.id;
        String staffEmail = staffData["Email"] ?? "Staff";

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverEmail: staffEmail,
              receiverID: staffId,
            ),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No staff assigned to this car yet.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void sortCars(List<Map<String, dynamic>> cars) {
    switch (sortType) {
      case SortType.priceLow:
        cars.sort((a, b) => (double.tryParse(a["Price"]?.toString() ?? '0') ?? 0.0)
            .compareTo(double.tryParse(b["Price"]?.toString() ?? '0') ?? 0.0));
        break;
      case SortType.priceHigh:
        cars.sort((a, b) => (double.tryParse(b["Price"]?.toString() ?? '0') ?? 0.0)
            .compareTo(double.tryParse(a["Price"]?.toString() ?? '0') ?? 0.0));
        break;
      case SortType.yearNew:
        cars.sort((a, b) => (int.tryParse(b["Year"]?.toString() ?? '0') ?? 0)
            .compareTo(int.tryParse(a["Year"]?.toString() ?? '0') ?? 0));
        break;
      case SortType.yearOld:
        cars.sort((a, b) => (int.tryParse(a["Year"]?.toString() ?? '0') ?? 0)
            .compareTo(int.tryParse(b["Year"]?.toString() ?? '0') ?? 0));
        break;
      case SortType.none:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    String keyword = _searchController.text.toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: Text("Search Cars"),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark_added_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserBookingListPage()),
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
              decoration: InputDecoration(
                hintText: "Search for your dream car...",
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search_rounded, color: Theme.of(context).colorScheme.primary),
                filled: true,
                fillColor: Theme.of(context).colorScheme.secondary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
              onChanged: (v) {
                setState(() {});
              },
            ),
          ),


          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                DropdownButton<SortType>(
                  value: sortType,
                  underline: SizedBox(),
                  items: [
                    DropdownMenuItem(
                      value: SortType.none,
                      child: Text("Default"),
                    ),
                    DropdownMenuItem(
                      value: SortType.priceLow,
                      child: Text("Price ↑"),
                    ),
                    DropdownMenuItem(
                      value: SortType.priceHigh,
                      child: Text("Price ↓"),
                    ),
                    DropdownMenuItem(
                      value: SortType.yearNew,
                      child: Text("Newest Year"),
                    ),
                    DropdownMenuItem(
                      value: SortType.yearOld,
                      child: Text("Oldest Year"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      sortType = value!;
                    });
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 5),

          /// CAR LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("Cars")
                  .where("Status", isEqualTo: "available")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var docs = snapshot.data!.docs;

                List<Map<String, dynamic>> cars = docs.map((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  data["id"] = doc.id;
                  return data;
                }).toList();

                /// FILTER
                cars = cars.where((car) {
                  String brand = (car["Brand"] ?? "").toLowerCase();
                  String model = (car["Model"] ?? "").toLowerCase();
                  return brand.contains(keyword) || model.contains(keyword);
                }).toList();

                sortCars(cars);

                if (cars.isEmpty) {
                  return Center(child: Text("No cars found"));
                }

                return ListView.builder(
                  itemCount: cars.length,
                  itemBuilder: (context, index) {
                    var car = cars[index];
                    String carId = car["id"];

                    String image = "";
                    if (car["Images"] != null && car["Images"].isNotEmpty) {
                      image = car["Images"][0];
                    }

                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// IMAGE + OVERLAYS
                            Stack(
                              children: [
                                GestureDetector(
                                  onTap: () => openDetail(car),
                                  child: image.isNotEmpty
                                      ? Hero(
                                          tag: carId,
                                          child: Image.network(
                                            image,
                                            height: 220,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Container(
                                          height: 220,
                                          width: double.infinity,
                                          color: Theme.of(context).colorScheme.tertiary,
                                          child: Icon(
                                            Icons.directions_car_filled_rounded,
                                            size: 64,
                                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                          ),
                                        ),
                                ),

                                /// FAVORITE BUTTON
                                Positioned(
                                  right: 12,
                                  top: 12,
                                  child: StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection("Users")
                                        .doc(userId)
                                        .collection("favorites")
                                        .doc(carId)
                                        .snapshots(),
                                    builder: (context, favSnapshot) {
                                      bool isFav = favSnapshot.data?.exists ?? false;

                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: Icon(
                                            isFav ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                                            color: isFav ? Colors.redAccent : Colors.white,
                                          ),
                                          onPressed: () => toggleFavorite(carId, car),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                /// PRICE TAG
                                Positioned(
                                  left: 12,
                                  bottom: 12,
                                  child: Container(
                                    padding:  EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      "฿${car["Price"]}",
                                      style:  TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            /// INFO
                            Padding(
                              padding:  EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${car["Brand"]} ${car["Model"]}",
                                          style:  TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 16,
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                      ),
                                    ],
                                  ),
                                   SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _buildInfoBadge(context, Icons.calendar_today_rounded, car["Year"].toString()),
                                       SizedBox(width: 8),
                                      _buildInfoBadge(context, Icons.speed_rounded, "${car["Mileage"]}km"),
                                    ],
                                  ),
                                   SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          icon:  Icon(Icons.chat_bubble_outline_rounded, size: 18),
                                          label:  Text("Chat with Staff"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                            foregroundColor: Theme.of(context).colorScheme.primary,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                            padding:  EdgeInsets.symmetric(vertical: 12),
                                          ),
                                          onPressed: () => openChat(carId),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(BuildContext context, IconData icon, String label) {
    return Container(
      padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
           SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class CarDetailPage extends StatefulWidget {
  final Map<String, dynamic> car;
 
   CarDetailPage({super.key, required this.car});

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
        title:  Text("Confirm Booking"),
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
                  // Capture ScaffoldMessenger before popping
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  
                  // Pop the confirm dialog
                  Navigator.pop(context); 
                  // Pop the CarDetailPage
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
            child:  Text("Confirm"),
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
                          style:  TextStyle(
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
                padding:  EdgeInsets.all(24),
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
                          padding:  EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: ((widget.car["Status"]?.toString().toLowerCase() == "available" || widget.car["Status"] == null) 
                                ? Colors.green 
                                : Theme.of(context).colorScheme.primary).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.car["Status"]?.toString().toUpperCase() ?? "AVAILABLE",
                            style: TextStyle(
                              color: (widget.car["Status"]?.toString().toLowerCase() == "available" || widget.car["Status"] == null) 
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
      

      bottomSheet: Container(
        padding:  EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(top: BorderSide(color: Theme.of(context).colorScheme.tertiary, width: 0.5)),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            minimumSize:  Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 8,
            shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
          ),
          onPressed: _showBookingDialog,
          child:  Text("Book Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildSpecCard(BuildContext context, IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding:  EdgeInsets.all(16),
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
            Text(label, style:  TextStyle(color: Colors.grey, fontSize: 12)),
             SizedBox(height: 4),
            Text(value, style:  TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
