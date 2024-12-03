class User {
  String uid; // Unique user ID from Firebase Authentication
  String name; // User's name
  String email; // User's email address
  String phone; // User's phone number
  String profilePicture; // URL to the user's profile picture
  List<String> friends; // List of friend UIDs

  User({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.profilePicture,
    required this.friends,
  });

  // Factory method to create a User object from Firestore data
  factory User.fromFirestore(String uid, Map<String, dynamic> data) {
    return User(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      profilePicture: data['profilePicture'] ?? '',
      friends: List<String>.from(data['friends'] ?? []),
    );
  }

  // Convert a User object to a Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'profilePicture': profilePicture,
      'friends': friends,
    };
  }
}
