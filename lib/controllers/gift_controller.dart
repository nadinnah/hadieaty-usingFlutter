import '../models/gift.dart';

class GiftController {
  // A dummy list of gifts for demonstration purposes
  final List<Gift> _gifts = [
    Gift(
        name: "Smartphone",
        description: "A brand-new smartphone",
        category: "Electronics",
        price: 699.99,
        imageUrl: "",
        status: "available"),
    Gift(
        name: "Book",
        description: "A thriller novel",
        category: "Books",
        price: 19.99,
        imageUrl: "",
        status: "pledged"),
  ];

  // Get all gifts
  List<Gift> getGifts() {
    return List<Gift>.from(_gifts);
  }

  // Search gifts by name
  List<Gift> searchGifts(String query) {
    return _gifts
        .where((gift) => gift.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Sort gifts by name
  List<Gift> sortByName() {
    _gifts.sort((a, b) => a.name.compareTo(b.name));
    return getGifts();
  }

  // Sort gifts by category
  List<Gift> sortByCategory() {
    _gifts.sort((a, b) => a.category.compareTo(b.category));
    return getGifts();
  }

  // Sort gifts by status
  List<Gift> sortByStatus() {
    _gifts.sort((a, b) => a.status.compareTo(b.status));
    return getGifts();
  }

  // Add a new gift
  void addGift(Gift gift) {
    _gifts.add(gift);
  }

  // Edit an existing gift
  void editGift(String oldName, Gift updatedGift) {
    int index = _gifts.indexWhere((gift) => gift.name == oldName);
    if (index != -1) {
      _gifts[index] = updatedGift;
    }
  }

  // Delete a gift by name
  void deleteGift(String giftName) {
    _gifts.removeWhere((gift) => gift.name == giftName);
  }

  // Mark a gift as pledged
  void togglePledgeStatus(String giftName) {
    int index = _gifts.indexWhere((gift) => gift.name == giftName);
    if (index != -1) {
      _gifts[index].status = _gifts[index].status == 'available'
          ? 'pledged'
          : 'available';
    }
  }
}
