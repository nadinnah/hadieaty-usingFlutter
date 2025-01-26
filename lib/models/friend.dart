class Friend {
  String id; // Firestore document ID
  String name;
  String profilePicture;
  String phone;
  int upcomingEventsCount;

  Friend({
    required this.id,
    required this.name,
    required this.profilePicture,
    required this.phone,
    required this.upcomingEventsCount,
  });

  /// Creates a `Friend` object from Firestore data.
  factory Friend.fromFirestore(String id, Map<String, dynamic> data) {
    return Friend(
      id: id,
      name: data['name'] ?? '',
      profilePicture: data['profilePicture'] ?? '',
      phone: data['phone'] ?? '',
      upcomingEventsCount: data['upcomingEventsCount'] ?? 0,
    );
  }

  /// Converts a `Friend` object into a map for Firestore storage.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'profilePicture': profilePicture,
      'phone': phone,
      'upcomingEventsCount': upcomingEventsCount,
    };
  }
}
