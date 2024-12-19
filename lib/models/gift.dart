class Gift {
  int? id; // Local database ID
  String firebaseId; // Firestore ID
  String name;
  String? description;
  String? category;
  double? price;
  String? imageUrl;
  String status; // "Available", "Pledged", "Purchased"
  String eventId; // Firestore event ID
  String syncStatus; // "Synced", "Unsynced"
  String? pledgedBy; // Firestore user ID of the pledger
  String createdBy; // Firestore user ID of the creator

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

  // Factory method: Convert from a map to a Gift object
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
      pledgedBy: map['pledgedBy'], // Firestore user ID of the pledger
      createdBy: map['createdBy'] ?? '', // Firestore user ID of the creator
    );
  }

  // Convert Gift object to a map for storage
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
