class Gift {
  int? id; // Nullable for database auto-incremented IDs
  String name;
  String? description; // Optional description
  String? category; // Optional category
  double? price; // Optional price
  String? imageUrl; // Optional image URL
  String status; // Gift status (e.g., "Available", "Reserved")
  int eventId; // Foreign key to the event
  bool syncStatus; // True if synced, false otherwise

  Gift({
    this.id,
    required this.name,
    this.description,
    this.category,
    this.price,
    this.imageUrl,
    required this.status,
    required this.eventId,
    required this.syncStatus,
  });

  // Factory method: Convert from a map to a Gift object
  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'], // Nullable ID
      name: map['name'] ?? '', // Default to empty string if null
      description: map['description'],
      category: map['category'],
      price: map['price'] != null ? (map['price'] as num).toDouble() : null, // Ensure price is double
      imageUrl: map['imageUrl'],
      status: map['status'] ?? 'Available', // Default to "Available" if null
      eventId: map['eventId'] ?? 0, // Default to 0 if null (though ideally required)
      // Ensure syncStatus works for 1/0 and true/false
      syncStatus: map['syncStatus'] == 1 || map['syncStatus'] == true,
    );
  }

  // Convert Gift object to a map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Include ID if it's not null
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'status': status,
      'eventId': eventId,
      // Store syncStatus as 1 for true, 0 for false
      'syncStatus': syncStatus ? 1 : 0,
    };
  }

  // Helper: Check if a gift is empty (no meaningful data)
  bool isEmpty() {
    return name.isEmpty && (description?.isEmpty ?? true);
  }

  // Static factory: Provide an empty gift template
  static final Gift empty = Gift(
    id: null,
    name: '',
    description: null,
    category: null,
    price: null,
    imageUrl: null,
    status: 'Available',
    eventId: 0,
    syncStatus: false,
  );
}
