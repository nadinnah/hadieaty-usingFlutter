class Event {
  final int _id;
  final String _name;
  final DateTime _date;
  final String _location;
  final String _description;
  final int _userId;

  Event(this._id, this._name, this._date, this._location, this._description, this._userId);

  int get id => _id;
  String get name => _name;
  DateTime get date => _date;
  String get location => _location;
  String get description => _description;
  int get userId => _userId;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    if (_id != null) {
      map['id'] = _id;
    }
    map['name'] = _name;
    map['date'] = _date.toIso8601String();
    map['location'] = _location;
    map['description'] = _description;
    map['userId'] = _userId;
    return map;
  }

  Event.fromMap(Map<String, dynamic> map)
      : _id = map['id'],
        _name = map['name'],
        _date = DateTime.parse(map['date']),
        _location = map['location'],
        _description = map['description'],
        _userId = map['userId'];
}