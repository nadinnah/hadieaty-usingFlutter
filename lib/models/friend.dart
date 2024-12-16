class Friend {
  String id; // Unique Firestore document ID
  String name;
  String profilePicture;
  String phone;
  int upcomingEventsCount; // Field for the count of upcoming events

  Friend({
    required this.id, // Firestore document ID
    required this.name,
    required this.profilePicture,
    required this.phone,
    required this.upcomingEventsCount,
  });

  // Factory method to create a Friend object from Firestore data
  factory Friend.fromFirestore(String id, Map<String, dynamic> data) {
    return Friend(
      id: id,
      name: data['name'] ?? '',
      profilePicture: data['profilePicture'] ?? '',
      phone: data['phone'] ?? '',
      upcomingEventsCount: data['upcomingEventsCount'] ?? 0,
    );
  }

  // Converts Friend object into a Map for Firestore storage
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'profilePicture': profilePicture,
      'phone': phone,
      'upcomingEventsCount': upcomingEventsCount,
    };
  }
}
