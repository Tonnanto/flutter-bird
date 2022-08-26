import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

import 'persistence_service.dart';

class LocalKeyValuePersistence implements Repository {
  
  static String flappyKey = 'flappy_key';
  
  String _generateKey(String key) {
    return key;
  }

  @override
  Future<Uint8List?> getImage(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final base64Image = prefs.getString(_generateKey(key));
    if (base64Image != null) return const Base64Decoder().convert(base64Image);
    return null;
  }

  @override
  Future<Map<String, dynamic>?> getObject(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final objectString = prefs.getString(_generateKey(key));
    if (objectString != null) return const JsonDecoder().convert(objectString) as Map<String, dynamic>;
    return null;
  }

  @override
  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_generateKey(key));
  }

  @override
  Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_generateKey(key));
  }

  @override
  Future<void> removeImage(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_generateKey(key));
  }

  @override
  Future<void> removeObject(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_generateKey(key));
  }

  @override
  Future<void> removeString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_generateKey(key));
  }

  @override
  Future<void> removeInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_generateKey(key));
  }

  @override
  Future<String> saveImage(String key, Uint8List image) async {
    final base64Image = const Base64Encoder().convert(image);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_generateKey(key), base64Image);
    return key;
  }

  @override
  void saveObject(String key, Map<String, dynamic> object) async {
    final prefs = await SharedPreferences.getInstance();
    final string = const JsonEncoder().convert(object);
    await prefs.setString(_generateKey(key), string);
  }

  @override
  void saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_generateKey(key), value);
  }

  @override
  void saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_generateKey(key), value);
  }
}