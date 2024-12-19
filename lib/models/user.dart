import 'event.dart';
import 'gift.dart';

class User {
  int? id; // Unique database identifier
  String name;
  String email;
  bool notifications;
  String? fcmToken; // Firebase Cloud Messaging Token
  List<Event> createdEvents;
  List<Gift> pledgedGifts;

  User({
    this.id,
    required this.name,
    required this.email,
    this.notifications = true,
    this.fcmToken,
    this.createdEvents = const [],
    this.pledgedGifts = const [],
  });

  // Convert User object to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'notifications': notifications ? 1 : 0, // Store as int in SQLite
      'fcmToken': fcmToken,
    };
  }

  // Create User object from map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      notifications: map['notifications'] == 1, // Convert int to bool
      fcmToken: map['fcmToken'],
    );
  }
}
