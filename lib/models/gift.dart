class Gift {
  String name;
  String description;
  String category;
  double price;
  String imageUrl;
  String status; // available or pledged

  Gift({
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    this.status = 'available',
  });
}
