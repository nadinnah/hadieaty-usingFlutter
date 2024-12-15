class Event {
  int? id; // Nullable for database auto-incremented IDs
  String name;
  String description;
  String date; // ISO 8601 date format (e.g., "2024-12-15")
  String location;
  String category;
  String status; // Event status (e.g., "Upcoming", "Completed")
  String createdAt; // ISO 8601 date format for creation timestamp
  String userId; // Foreign key to the user
  bool syncStatus; // True if synced, false otherwise

  Event({
    this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.location,
    required this.category,
    required this.status,
    required this.createdAt,
    required this.userId,
    required this.syncStatus,
  });

  // Factory method: Convert from a map to an Event object
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'], // Nullable ID
      name: map['name'] ?? '', // Default to empty string if null
      description: map['description'] ?? '',
      date: map['date'] ?? '', // Ensure date is a string
      location: map['location'] ?? '',
      category: map['category'] ?? '',
      status: map['status'] ?? '',
      createdAt: map['createdAt'] ?? '',
      userId: map['userId'] ?? '',
      // Ensure syncStatus works for 1/0 and true/false
      syncStatus: map['syncStatus'] == 1 || map['syncStatus'] == true,
    );
  }

  // Convert Event object to a map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Include ID if it's not null
      'name': name,
      'description': description,
      'date': date,
      'location': location,
      'category': category,
      'status': status,
      'createdAt': createdAt,
      'userId': userId,
      // Store syncStatus as 1 for true, 0 for false
      'syncStatus': syncStatus ? 1 : 0,
    };
  }

  // Helper: Check if an event is empty (no meaningful data)
  bool isEmpty() {
    return name.isEmpty && description.isEmpty && date.isEmpty;
  }

  // Static factory: Provide an empty event template
  static final Event empty = Event(
    id: null,
    name: '',
    description: '',
    date: '',
    location: '',
    category: '',
    status: '',
    createdAt: '',
    userId: '',
    syncStatus: false,
  );
}
