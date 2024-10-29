class User {
  final int _id;
  final String _name;
  final String _email;
  final String _preferences;

  User(this._id, this._name, this._email, this._preferences);

  int get id => _id;
  String get name => _name;
  String get email => _email;
  String get preferences => _preferences;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    if (_id != null) {
      map['id'] = _id;
    }
    map['name'] = _name;
    map['email'] = _email;
    map['preferences'] = _preferences;
    return map;
  }

  User.fromMap(Map<String, dynamic> map)
      : _id = map['id'],
        _name = map['name'],
        _email = map['email'],
        _preferences = map['preferences'];
}