import 'event.dart';
import 'gift.dart';

class User {
  String id; // Unique identifier for the user
  String name;
  String email;
  bool notifications; // Notification settings (enabled/disabled)
  List<Event> createdEvents; // List of events created by the user
  List<Gift> pledgedGifts; // List of gifts pledged by the user

  User({
    required this.id,
    required this.name,
    required this.email,
    this.notifications = true, // Default to notifications enabled
    this.createdEvents = const [], // Default to an empty list
    this.pledgedGifts = const [], // Default to an empty list
  });

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
