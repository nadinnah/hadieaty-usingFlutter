class Gift {
  final int _id;
  final String _name;
  final String _description;
  final String _category;
  final double _price;
  final String _status;
  final int _eventId;

  Gift(this._id, this._name, this._description, this._category, this._price, this._status, this._eventId);

  int get id => _id;
  String get name => _name;
  String get description => _description;
  String get category => _category;
  double get price => _price;
  String get status => _status;
  int get eventId => _eventId;

  // Convert Gift to a Map for SQLite
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    if (_id != null) {
      map['id'] = _id;
    }
    map['name'] = _name;
    map['description'] = _description;
    map['category'] = _category;
    map['price'] = _price;
    map['status'] = _status;
    map['eventId'] = _eventId;
    return map;
  }

  Gift.fromMap(Map<String, dynamic> map)
      : _id = map['id'],
        _name = map['name'],
        _description = map['description'],
        _category = map['category'],
        _price = map['price'],
        _status = map['status'],
        _eventId = map['eventId'];
}
