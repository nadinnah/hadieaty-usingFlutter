class Gift {
  int? id;
  String firebaseId;
  String name;
  String? description;
  String? category;
  double? price;
  String? imageUrl;
  String status;
  String eventId;
  String syncStatus;
  String? pledgedBy;
  String createdBy;

  Gift({
    this.id,
    this.firebaseId = '',
    required this.name,
    this.description,
    this.category,
    this.price,
    this.imageUrl,
    required this.status,
    required this.eventId,
    required this.syncStatus,
    this.pledgedBy,
    required this.createdBy,
  });

  /// Creates a `Gift` object from a map.
  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'],
      firebaseId: map['firebaseId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      category: map['category'],
      price: map['price'] != null ? (map['price'] as num).toDouble() : null,
      imageUrl: map['imageUrl'],
      status: map['status'] ?? 'Available',
      eventId: map['eventId'] ?? '',
      syncStatus: map['syncStatus'] ?? 'Unsynced',
      pledgedBy: map['pledgedBy'],
      createdBy: map['createdBy'] ?? '',
    );
  }

  /// Converts a `Gift` object to a map for storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'status': status,
      'eventId': eventId,
      'syncStatus': syncStatus,
      'pledgedBy': pledgedBy,
      'createdBy': createdBy,
    };
  }
}
