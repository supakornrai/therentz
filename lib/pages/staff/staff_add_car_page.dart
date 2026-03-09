import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_rentz/components/my_textfield.dart';

class StaffAddCarPage extends StatefulWidget {
  const StaffAddCarPage({super.key});

  @override
  State<StaffAddCarPage> createState() => _AddCarPageState();
}

class _AddCarPageState extends State<StaffAddCarPage> {
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _takePhoto() async {
  try {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1080, 
      imageQuality: 85,
    );
    
    if (photo != null) {
      setState(() {
        _selectedImages.add(File(photo.path));
      });
    }
  } on PlatformException catch (e) {
    debugPrint("Camera error: $e");
    final XFile? galleryImage = await _picker.pickImage(source: ImageSource.gallery);
    if (galleryImage != null) {
      setState(() => _selectedImages.add(File(galleryImage.path)));
    }
  }
}

  Future<void> _uploadCar() async {
    if (_brandController.text.isEmpty || _selectedImages.isEmpty) return;

    setState(() => _isLoading = true);
    final String staffId = FirebaseAuth.instance.currentUser!.uid;

    try {
      List<String> imageUrls = [];

      for (var image in _selectedImages) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref = FirebaseStorage.instance.ref().child('cars/$fileName');
        await ref.putFile(image);
        String url = await ref.getDownloadURL();
        imageUrls.add(url);
      }

      await FirebaseFirestore.instance.collection("Cars").add({
        'Brand': _brandController.text,
        'Model': _modelController.text,
        'Price': double.parse(_priceController.text),
        'Images': imageUrls,
        'TentId': staffId, 
        'Status': 'available',
        'Timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('A D D C A R'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _selectedImages.isEmpty 
                    ? const Center(child: Text("No photos taken"))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, i) => Image.file(_selectedImages[i]),
                      ),
                ),
                const SizedBox(height: 10),
                
                // Camera Button
                ElevatedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Take Photo"),
                ),

                const SizedBox(height: 20),
                MyTextField(controller: _brandController, hintText: 'Brand', obscureText: false),
                const SizedBox(height: 10,),        
                MyTextField(controller: _modelController, hintText: 'Model', obscureText: false),        
                const SizedBox(height: 10,),
                MyTextField(controller: _priceController, hintText: 'Price', obscureText: false),        
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _uploadCar,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: const Text("List Car for Sale"),
                ),
              ],
            ),
          ),
    );
  }
}