class Car {
  final String id;
  final String brand;
  final String model;
  final double price;
  final List<String> images;
  final String tentId;

  Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.price,
    required this.images,
    required this.tentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'Id' : id,
      'Brand' : brand,
      'Model' : model,
      'Price' : price,
      'Images' : images,
      'TentId' : tentId,
    };
  }

  factory Car.fromMap(Map<String, dynamic> data, String id) {
    return Car(
      id: id,
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      images: List<String>.from(data['images'] ?? []),
      tentId: data['tentId'] ?? '',
    );
  }
}