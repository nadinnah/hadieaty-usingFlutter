class Gift {
  int? id;
  String name;
  String description;
  String category;
  double price;
  String imageUrl;
  String status; // available or pledged
  int eventId;

  Gift({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.status,
    required this.eventId,
  });

  // Convert Gift object to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'status': status,
      'eventId': eventId,
    };
  }

  // Create Gift object from map
  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      price: map['price'],
      imageUrl: map['imageUrl'],
      status: map['status'],
      eventId: map['eventId'],
    );
  }
}
