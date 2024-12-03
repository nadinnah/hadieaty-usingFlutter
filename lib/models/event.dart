class Event {
  String name;
  String description;
  String date; // Event date
  String location;
  String category;  // Category of the event (e.g., Party, Concert)
  String status;    // Status of the event ("Upcoming", "Current", "Past")
  String createdAt; // Date when the event was created (new field)

  Event({
    required this.name,
    required this.description,
    required this.date,
    required this.location,
    required this.category,
    required this.status,
    required this.createdAt, // Initialize createdAt
  });

  // Convert Event object to a map (for database or network storage)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'date': date,
      'location': location,
      'category': category,
      'status': status,
      'createdAt': createdAt, // Add createdAt to map
    };
  }

  // Create Event object from map (for database or data source)
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      name: map['name'],
      description: map['description'],
      date: map['date'],
      location: map['location'],
      category: map['category'],
      status: map['status'],
      createdAt: map['createdAt'], // Get createdAt from map
    );
  }
}
