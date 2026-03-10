import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StaffManageCarPage extends StatelessWidget {
  final String carId;

  StaffManageCarPage({super.key, required this.carId});

  void deleteCar() {
    FirebaseFirestore.instance.collection("Cars").doc(carId).delete();
  }

  void updateStatus(String status) {
    FirebaseFirestore.instance.collection("Cars").doc(carId).update({
      "Status": status,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Manage Car")),

      body: Padding(
        padding: EdgeInsets.all(20),

        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                updateStatus("available");
              },

              child: Text("Set Available"),
            ),

            ElevatedButton(
              onPressed: () {
                updateStatus("reserved");
              },

              child: Text("Set Reserved"),
            ),

            ElevatedButton(
              onPressed: () {
                updateStatus("sold");
              },

              child: Text("Set Sold"),
            ),

            SizedBox(height: 30),

            ElevatedButton(
              onPressed: deleteCar,

              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

              child: Text("Delete Car"),
            ),
          ],
        ),
      ),
    );
  }
}
