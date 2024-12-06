import '../models/gift.dart';

import '../services/sqlite_service.dart';  // Import your LocalDatabase class

class GiftController {
  final LocalDatabase _localDatabase = LocalDatabase();  // Instance of the LocalDatabase class

  // Get all gifts
  Future<List<Gift>> getGifts(int eventId) async {
    // Fetch gifts for the given event ID from the database
    var giftData = await _localDatabase.getGiftsByEventId(eventId);
    return giftData.map((gift) => Gift.fromMap(gift)).toList();
  }

  // Search gifts by name
  Future<List<Gift>> searchGifts(int eventId, String query) async {
    var giftData = await _localDatabase.searchGifts(eventId, query);
    return giftData.map((gift) => Gift.fromMap(gift)).toList();
  }

  // Sort gifts by name
  Future<List<Gift>> sortByName(int eventId) async {
    var giftData = await _localDatabase.getGiftsByEventId(eventId);
    giftData.sort((a, b) => a['name'].compareTo(b['name']));
    return giftData.map((gift) => Gift.fromMap(gift)).toList();
  }

  // Sort gifts by category
  Future<List<Gift>> sortByCategory(int eventId) async {
    var giftData = await _localDatabase.getGiftsByEventId(eventId);
    giftData.sort((a, b) => a['category'].compareTo(b['category']));
    return giftData.map((gift) => Gift.fromMap(gift)).toList();
  }

  // Sort gifts by status
  Future<List<Gift>> sortByStatus(int eventId) async {
    var giftData = await _localDatabase.getGiftsByEventId(eventId);
    giftData.sort((a, b) => a['status'].compareTo(b['status']));
    return giftData.map((gift) => Gift.fromMap(gift)).toList();
  }

  // Add a new gift
  Future<void> addGift(Gift gift) async {
    await _localDatabase.insertGift(gift);  // Insert the gift into the database
  }

  // Edit an existing gift
  Future<void> editGift(int giftId, Gift updatedGift) async {
    await _localDatabase.updateGift(giftId, updatedGift);  // Update the gift in the database
  }

  // Delete a gift by ID
  Future<void> deleteGift(int giftId) async {
    await _localDatabase.deleteGift(giftId);  // Delete the gift from the database
  }

  // Mark a gift as pledged or available
  Future<void> togglePledgeStatus(int giftId) async {
    var gift = await _localDatabase.getGiftById(giftId);  // Fetch the gift by its ID
    if (gift != null) {
      String newStatus = gift['status'] == 'available' ? 'pledged' : 'available';
      await _localDatabase.updateGiftStatus(giftId, newStatus);  // Update the status in the database
    }
  }
}
