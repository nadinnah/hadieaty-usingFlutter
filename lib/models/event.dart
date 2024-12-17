class Event {
  dynamic id; // SQLite ID
  String? firebaseId; // Firestore Document ID
  String name;
  String date;
  String location;
  String description;
  String createdBy; // Firebase userId (creator's UID)
  String status;
  String category;
  bool syncStatus;
  String createdAt; // New createdAt field

  Event({
    this.id,
    this.firebaseId,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.createdBy, // Store the Firebase UID here
    required this.status,
    required this.category,
    this.syncStatus = false,
    required this.createdAt, // Accept createdAt as a required parameter
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'name': name,
      'date': date,
      'location': location,
      'description': description,
      'createdBy': createdBy, // Store createdBy
      'status': status,
      'category': category,
      'syncStatus': syncStatus ? 'synced' : 'unsynced',
      'createdAt': createdAt, // Add createdAt to the map
    };
  }

  // Create Event from Map
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] as int?,
      firebaseId: map['firebaseId'] as String?,
      name: map['name'] as String,
      date: map['date'] as String,
      location: map['location'] as String,
      description: map['description'] as String,
      createdBy: map['createdBy'] as String, // Parse createdBy (Firebase UID)
      status: map['status'] as String,
      category: map['category'] as String,
      syncStatus: map['syncStatus'] == 'synced',
      createdAt: map['createdAt'] as String, // Parse createdAt from the map
    );
  }
}
