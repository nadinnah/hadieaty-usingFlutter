import '../models/event.dart';
import '../services/sqlite_service.dart';

class EventController {
  LocalDatabase localdb = LocalDatabase();

  addEvent(Event event) async {
    int eventId = await localdb.insertEvent(event);
    //returns the event's id when stored in database (autoincremented)
    event.id = eventId;//can delete using that id stored
  }


  getEvents() async {
    var eventData = await localdb.getEvents();
    return eventData.map((event) => Event.fromMap(event)).toList();
  }

  // Update an event
  Future<void> updateEvent(Event event) async {
    await localdb.updateEvent(event);
  }

  // Delete an event
  Future<void> deleteEvent(int eventId) async {
    await localdb.deleteEvent(eventId);
  }
}
