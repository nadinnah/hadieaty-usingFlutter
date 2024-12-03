class Gift {
  String name;
  String description;
  double price;
  String status; // Pledged or available

  Gift({required this.name, required this.description, required this.price, required this.status});

  // Convert Firestore document to Gift object
  factory Gift.fromFirestore(Map<String, dynamic> data) {
    return Gift(
      name: data['name'],
      description: data['description'],
      price: data['price'],
      status: data['status'],
    );
  }
}
