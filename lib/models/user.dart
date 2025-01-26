import 'event.dart';
import 'gift.dart';

class User {
  int? id;
  String name;
  String email;
  bool notifications;
  String? fcmToken;
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

  /// Converts a `User` object to a map for storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'notifications': notifications ? 1 : 0,
      'fcmToken': fcmToken,
    };
  }

  /// Creates a `User` object from a map.
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      notifications: map['notifications'] == 1,
      fcmToken: map['fcmToken'],
    );
  }
}
