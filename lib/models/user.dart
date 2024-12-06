import 'event.dart';
import 'gift.dart';

class User {
  int? id; // Unique database identifier
  String name;
  String email;
  bool notifications;
  List<Event> createdEvents;
  List<Gift> pledgedGifts;

  User({
    this.id,
    required this.name,
    required this.email,
    this.notifications = true,
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
    };
  }

  // Create User object from map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      notifications: map['notifications'] == 1, // Convert int to bool
    );
  }


  // Method to update personal information
  void updateInfo({String? name, String? email, bool? notifications}) {
    if (name != null) {
      this.name = name;
    }
    if (email != null) {
      this.email = email;
    }
    if (notifications != null) {
      this.notifications = notifications;
    }
  }

  // Method to add an event
  void addEvent(Event event) {
    createdEvents.add(event);
  }

  // Method to add a pledged gift
  void addPledgedGift(Gift gift) {
    pledgedGifts.add(gift);
  }

  // Method to remove a pledged gift
  void removePledgedGift(String giftName) {
    pledgedGifts.removeWhere((gift) => gift.name == giftName);
  }


}
