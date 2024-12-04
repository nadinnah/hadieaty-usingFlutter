import '../models/event.dart';
import '../models/gift.dart';

class UserController {
  // Dummy data for created events
  List<Event> getCreatedEvents() {
    return [
      Event(
        name: "Birthday Party",
        description: "A fun birthday party",
        date: "2025-01-01",
        location: "Home",
        category: "Party",
        status: "Upcoming",
        createdAt: "2024-12-01",
      ),
      Event(
        name: "Wedding",
        description: "A beautiful wedding",
        date: "2025-05-15",
        location: "Beach",
        category: "Celebration",
        status: "Upcoming",
        createdAt: "2024-12-05",
      ),
    ];
  }

  // Dummy data for pledged gifts
  List<Gift> getPledgedGifts() {
    return [
      Gift(
        name: "Smartphone",
        description: "A brand-new smartphone",
        category: "Electronics",
        price: 699.99,
        imageUrl: "",
        status: "pledged",
      ),
      Gift(
        name: "Book",
        description: "A thriller novel",
        category: "Books",
        price: 19.99,
        imageUrl: "",
        status: "pledged",
      ),
    ];
  }
}
