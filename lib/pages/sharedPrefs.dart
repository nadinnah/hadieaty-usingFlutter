import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:hadieaty/Localdb/localDb.dart';

class PreferencesService extends ChangeNotifier {
  bool _isDarkMode = false;
  final LocalDatabase _localDatabase = LocalDatabase();

  bool get isDarkMode => _isDarkMode;

  PreferencesService() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = value;
    await prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> savePreferencesToDatabase(int userId) async {
    final preferences = {
      'isDarkMode': _isDarkMode,
    };
    final preferencesJson = jsonEncode(preferences); // Convert to JSON string

    // Save preferences to SQLite database
    final db = await _localDatabase.MyDataBase;
    await db!.execute('''
      UPDATE Users 
      SET preferences = ? 
      WHERE id = ?
    ''', [preferencesJson, userId]);
  }

  // Function to load preferences from SQLite
  Future<void> loadPreferencesFromDatabase(int userId) async {
    final db = await _localDatabase.MyDataBase;
    List<Map> result = await db!.rawQuery('''
      SELECT preferences FROM Users WHERE id = ?
    ''', [userId]);

    if (result.isNotEmpty && result[0]['preferences'] != null) {
      String preferencesJson = result[0]['preferences'];
      Map<String, dynamic> preferences = jsonDecode(preferencesJson);
      _isDarkMode = preferences['isDarkMode'];
      notifyListeners();
    }
  }
}
