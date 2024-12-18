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

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] ,
      firebaseId: map['firebaseId'], // Allow firebaseId to be null
      name: map['name'] as String? ?? 'Unknown Event', // Fallback to 'Unknown Event'
      date: (map['date'] is Timestamp)
          ? (map['date'] as Timestamp).toDate().toIso8601String() // Convert Timestamp to String
          : (map['date'] as String? ?? ''), // Handle null for date
      location: map['location'] as String? ?? 'No Location', // Fallback to 'No Location'
      description: map['description'] as String? ?? 'No Description', // Fallback to 'No Description'
      createdBy: map['createdBy'] as String? ?? 'Unknown Creator', // Fallback for createdBy
      status: map['status'] as String? ?? 'Unknown Status', // Fallback for status
      category: map['category'] as String? ?? 'Uncategorized', // Fallback for category
      syncStatus: map['syncStatus'] == 'synced',
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate().toIso8601String() // Handle Timestamp
          : (map['createdAt'] as String? ?? ''), // Handle null for createdAt
    );
  }


}
