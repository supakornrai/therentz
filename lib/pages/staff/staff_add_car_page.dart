import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:the_rentz/services/cloudinary_service.dart';

class StaffAddCarPage extends StatefulWidget {
  final Map<String, dynamic>? car;
  StaffAddCarPage({super.key, this.car});

  @override
  State<StaffAddCarPage> createState() => _StaffAddCarPageState();
}

class _StaffAddCarPageState extends State<StaffAddCarPage> {
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _mileController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  List<File> _selectedImages = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.car != null) {
      _brandController.text = widget.car!["Brand"] ?? "";
      _modelController.text = widget.car!["Model"] ?? "";
      _yearController.text = widget.car!["Year"]?.toString() ?? "";
      _mileController.text = widget.car!["Mileage"]?.toString() ?? "";
      _descriptionController.text = widget.car!["Description"] ?? "";
      _priceController.text = widget.car!["Price"]?.toString() ?? "";
    }
  }

  bool get _isFormValid {
    return _brandController.text.isNotEmpty &&
        _modelController.text.isNotEmpty &&
        _yearController.text.isNotEmpty &&
        _mileController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        (_selectedImages.isNotEmpty || (widget.car != null && (widget.car!["Images"] as List?)?.isNotEmpty == true));
  }

  Future<void> _takePhoto() async {
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
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _uploadCar() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<String> imageUrls = [];

      // Keep existing images if editing
      if (widget.car != null && widget.car!["Images"] != null) {
        imageUrls.addAll(List<String>.from(widget.car!["Images"]));
      }

      for (var image in _selectedImages) {
        String url = await uploadToCloudinary(image);
        imageUrls.add(url);
      }

      final carData = {
        "Brand": _brandController.text.trim(),
        "Model": _modelController.text.trim(),
        "Year": int.tryParse(_yearController.text) ?? 0,
        "Mileage": int.tryParse(_mileController.text) ?? 0,
        "Description": _descriptionController.text.trim(),
        "Price": double.tryParse(_priceController.text) ?? 0,
        "Images": imageUrls,
        "Status": widget.car?["Status"] ?? "available",
        "Timestamp": FieldValue.serverTimestamp(),
      };

      if (widget.car != null && widget.car!["id"] != null) {
        // UPDATE
        await FirebaseFirestore.instance.collection("Cars").doc(widget.car!["id"]).update(carData);
      } else {
        // ADD NEW
        await FirebaseFirestore.instance.collection("Cars").add(carData);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(widget.car != null ? "Car updated successfully" : "Car listed successfully")));
      
      if (widget.car != null) {
        Navigator.pop(context); // Go back after editing
      } else {
        // Clear form if adding new
        _selectedImages.clear();
        _brandController.clear();
        _modelController.clear();
        _yearController.clear();
        _mileController.clear();
        _descriptionController.clear();
        _priceController.clear();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Action failed: $e")));
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(widget.car != null ? "Edit Car" : "List New Car"),
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Vehicle Photos",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Theme.of(context).colorScheme.tertiary, width: 1),
                    ),
                    child: _selectedImages.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_rounded,
                                    size: 40, color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                                SizedBox(height: 8),
                                Text(
                                  "No photos selected",
                                  style: TextStyle(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.all(12),
                            itemCount: _selectedImages.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 12),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.file(
                                        _selectedImages[index],
                                        width: 140,
                                        height: 140,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 15,
                                    top: 5,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.close_rounded, color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: Icon(Icons.camera_alt_rounded),
                    label: Text("Take Photo"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 32),
                  Text(
                    "Vehicle Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  _buildPremiumTextField(context, _brandController, "Brand", Icons.branding_watermark_rounded),
                  _buildPremiumTextField(context, _modelController, "Model", Icons.directions_car_rounded),
                  Row(
                    children: [
                      Expanded(
                          child: _buildPremiumTextField(context, _yearController, "Year", Icons.calendar_today_rounded,
                              isNumber: true)),
                      SizedBox(width: 16),
                      Expanded(
                          child: _buildPremiumTextField(context, _mileController, "Mileage", Icons.speed_rounded,
                              isNumber: true)),
                    ],
                  ),
                  _buildPremiumTextField(context, _descriptionController, "Description", Icons.info_outline_rounded),
                  _buildPremiumTextField(context, _priceController, "Price (฿)", Icons.payments_rounded, isNumber: true),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _isFormValid ? _uploadCar : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 8,
                      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                    ),
                    child: Text(
                      _isLoading ? "Processing..." : (widget.car != null ? "Save Changes" : "List Car Now"),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildPremiumTextField(BuildContext context, TextEditingController controller, String label, IconData icon,
      {bool isNumber = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
        style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary.withOpacity(0.6)),
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
          filled: true,
          fillColor: Theme.of(context).colorScheme.secondary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }
}
