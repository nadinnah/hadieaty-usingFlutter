import 'package:cloud_firestore/cloud_firestore.dart';

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
  String createdAt;

  Event({
    this.id,
    this.firebaseId,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.createdBy,
    required this.status,
    required this.category,
    this.syncStatus = false,
    required this.createdAt,
  });

  /// Converts the `Event` object to a map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firebaseId': firebaseId,
      'name': name,
      'date': date,
      'location': location,
      'description': description,
      'createdBy': createdBy,
      'status': status,
      'category': category,
      'syncStatus': syncStatus ? 'synced' : 'unsynced',
      'createdAt': createdAt,
    };
  }

  /// Creates an `Event` object from a map.
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      firebaseId: map['firebaseId'],
      name: map['name'] as String? ?? 'Unknown Event',
      date: (map['date'] is Timestamp)
          ? (map['date'] as Timestamp).toDate().toIso8601String()
          : (map['date'] as String? ?? ''),
      location: map['location'] as String? ?? 'No Location',
      description: map['description'] as String? ?? 'No Description',
      createdBy: map['createdBy'] as String? ?? 'Unknown Creator',
      status: map['status'] as String? ?? 'Unknown Status',
      category: map['category'] as String? ?? 'Uncategorized',
      syncStatus: map['syncStatus'] == 'synced',
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate().toIso8601String()
          : (map['createdAt'] as String? ?? ''),
    );
  }
}
