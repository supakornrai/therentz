import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserFavPage extends StatelessWidget {
  UserFavPage({super.key});

  final String userId = FirebaseAuth.instance.currentUser!.uid;

  void removeFavorite(BuildContext context, String carId) async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(userId)
        .collection("favorites")
        .doc(carId)
        .delete();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Removed from favorite")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("Favorite Cars"),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("Users").doc(userId).collection("favorites").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var favCars = snapshot.data!.docs;

          if (favCars.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border_rounded, size: 80, color: Colors.red.withOpacity(0.2)),
                  SizedBox(height: 16),
                  Text("No favorites yet", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: favCars.length,
            itemBuilder: (context, index) {
              var doc = favCars[index];
              var car = doc.data() as Map<String, dynamic>;
              String carId = doc.id;
              String image = (car["Images"] != null && car["Images"].isNotEmpty) ? car["Images"][0] : "";

              return Container(
                margin: EdgeInsets.only(bottom: 20),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Theme.of(context).colorScheme.tertiary, width: 0.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: image.isNotEmpty
                          ? Image.network(image, width: 100, height: 100, fit: BoxFit.cover)
                          : Container(
                              width: 100,
                              height: 100,
                              color: Theme.of(context).colorScheme.tertiary,
                              child: Icon(Icons.directions_car_rounded, size: 40),
                            ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${car["Brand"]} ${car["Model"]}",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Year ${car["Year"]}",
                            style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5)),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "฿${car["Price"]}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.favorite_rounded, color: Colors.red),
                      onPressed: () => removeFavorite(context, carId),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
