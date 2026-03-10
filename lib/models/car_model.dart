class Car {
  final String id;
  final String brand;
  final String model;
  final double price;
  final List<String> images;

  final String description;

  Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.price,
    required this.images,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Brand': brand,
      'Model': model,
      'Price': price,
      'Images': images,
      'Description': description,
    };
  }

  factory Car.fromMap(Map<String, dynamic> data, String id) {
    return Car(
      id: id,
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      price: (data['Price'] ?? 0).toDouble(),
      images: List<String>.from(data['Images'] ?? []),
      description: data['Description'] ?? '',
    );
  }
}
