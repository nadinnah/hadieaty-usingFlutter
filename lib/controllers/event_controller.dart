import '../models/event.dart';
import '../services/sqlite_service.dart';

class EventController {
  final LocalDatabase _localDatabase = LocalDatabase();

  // Get all events
  Future<void> addEvent(Event event) async {
    // Insert the event into the database
    int eventId = await _localDatabase.insertEvent(event);

    // Update the event object with the generated ID
    event.id = eventId;
  }

  // Fetch all events
  Future<List<Event>> getEvents() async {
    var eventData = await _localDatabase.getEvents();
    return eventData.map((event) => Event.fromMap(event)).toList();
  }

  // Update an event
  Future<void> updateEvent(Event event) async {
    await _localDatabase.updateEvent(event);
  }

  // Delete an event
  Future<void> deleteEvent(int eventId) async {
    await _localDatabase.deleteEvent(eventId);
  }
}
