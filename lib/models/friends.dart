class Friend {
  final int _userId;
  final int _friendId;

  Friend(this._userId, this._friendId);

  int get userId => _userId;
  int get friendId => _friendId;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['userId'] = _userId;
    map['friendId'] = _friendId;
    return map;
  }

  Friend.fromMap(Map<String, dynamic> map)
      : _userId = map['userId'],
        _friendId = map['friendId'];
}