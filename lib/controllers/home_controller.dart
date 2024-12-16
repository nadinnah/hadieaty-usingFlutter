
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hadieaty/models/friend.dart';

import '../services/firestore_service.dart';


class HomeController {
  // // Dummy list of friends with upcoming events
  // final List<Friend> _friends = [
  //   Friend(
  //     name: "John Doe",
  //     profilePicture:"https://dummyimage.com/150x150/cccccc/ffffff.png&text=Friend",
  //     phone: "+1234567890",
  //     upcomingEventsCount: 3,
  //   ),
  //   Friend(
  //     name: "Jane Smith",
  //     profilePicture: "https://dummyimage.com/150x150/cccccc/ffffff.png&text=Friend",
  //     phone: "+0987654321",
  //     upcomingEventsCount: 1,
  //   ),
  //   Friend(
  //     name: "Alice Brown",
  //     profilePicture:"https://dummyimage.com/150x150/cccccc/ffffff.png&text=Friend",
  //     phone: "+1112223333",
  //     upcomingEventsCount: 0,
  //   ),
  //   Friend(
  //     name: "John Doe",
  //     profilePicture:"https://dummyimage.com/150x150/cccccc/ffffff.png&text=Friend",
  //     phone: "+1234567890",
  //     upcomingEventsCount: 3,
  //   ),
  //   Friend(
  //     name: "Jane Smith",
  //     profilePicture: "https://dummyimage.com/150x150/cccccc/ffffff.png&text=Friend",
  //     phone: "+0987654321",
  //     upcomingEventsCount: 1,
  //   ),
  //   Friend(
  //     name: "Alice Brown",
  //     profilePicture:"https://dummyimage.com/150x150/cccccc/ffffff.png&text=Friend",
  //     phone: "+1112223333",
  //     upcomingEventsCount: 0,
  //   ),
  // ];

  // // Fetch all friends
  // List<Friend> getFriends() {
  //   return _friends;
  // }
  //
  // // Search friends by name
  // List<Friend> searchFriends(String query) {
  //   return _friends
  //       .where((friend) => friend.name.toLowerCase().contains(query.toLowerCase()))
  //       .toList();
  // }
}
