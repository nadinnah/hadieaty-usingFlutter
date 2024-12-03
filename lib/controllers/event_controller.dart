import '../models/event.dart';

class EventController {

  final List<Event> _events = [
    Event(
      name: "Birthday Party",
      description: "Join us for an exciting birthday party!",
      date: "2024-12-25",
      location: "Friend's House",
      category: "Party",
      status: "Upcoming",
      createdAt: "2024-11-20", // Dummy created date
    ),
    Event(
      name: "New Year's Eve Party",
      description: "Celebrate the new year with friends and family!",
      date: "2024-12-31",
      location: "Central Park",
      category: "Party",
      status: "Upcoming",
      createdAt: "2024-11-22", // Dummy created date
    ),
    Event(
      name: "Concert",
      description: "Live music concert featuring popular bands!",
      date: "2024-11-20",
      location: "Stadium",
      category: "Music",
      status: "Past",
      createdAt: "2024-10-10", // Dummy created date
    ),
  ];


  // Fetch all events
  List<Event> getEvents() {
    return _events;
  }

  // Search events by name
  List<Event> searchEvents(String query) {
    return _events.where((event) => event.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  // Sort events by name
  List<Event> sortByName() {
    _events.sort((a, b) => a.name.compareTo(b.name));
    return _events;
  }

  // Sort events by category
  List<Event> sortByCategory() {
    _events.sort((a, b) => a.category.compareTo(b.category));
    return _events;
  }

  // Sort events by status (Upcoming, Current, Past)
  List<Event> sortByStatus() {
    _events.sort((a, b) => a.status.compareTo(b.status));
    return _events;
  }

  // Add a new event
  void addEvent(Event event) {
    _events.add(event);
  }

  // Delete an event by name (for simplicity)
  void deleteEvent(String eventName) {
    _events.removeWhere((event) => event.name == eventName);
  }

  // Edit an event by name
  void editEvent(String oldName, Event updatedEvent) {
    int index = _events.indexWhere((event) => event.name == oldName);
    if (index != -1) {
      _events[index] = updatedEvent;
    }
  }
}
