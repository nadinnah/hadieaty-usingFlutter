class Event {
  int? id;
  String name;
  String description;
  String date;
  String location;
  String category;
  String status;
  String createdAt;

  Event({
    this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.location,
    required this.category,
    required this.status,
    required this.createdAt,
  });

  // Convert Event object to map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'date': date,
      'location': location,
      'category': category,
      'status': status,
      'createdAt': createdAt,
    };
  }

  // Create Event object from map for SQLite
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      date: map['date'],
      location: map['location'],
      category: map['category'],
      status: map['status'],
      createdAt: map['createdAt'],
    );
  }
}
