import 'dart:typed_data';

import 'key_value_persistence.dart';

abstract class Repository {
  void saveString(String key, String value);

  void saveInt(String key, int value);

  Future<String> saveImage(String key, Uint8List image);

  void saveObject(String key, Map<String, dynamic> object);

  Future<String?> getString(String key);

  Future<int?> getInt(String key);

  Future<Uint8List?> getImage(String key);

  Future<Map<String, dynamic>?> getObject(String key);

  Future<void> removeString(String key);

  Future<void> removeInt(String key);

  Future<void> removeImage(String key);

  Future<void> removeObject(String key);
}

class PersistenceService {
  // Singleton
  static final PersistenceService instance = PersistenceService._init(repository: LocalKeyValuePersistence());

  PersistenceService._init({required this.repository});

  Repository repository;
  final String separatorPattern = ', ';

  // keys
  final String highScoreKey = 'flutter_bird.high_score';

  Future<void> saveHighScore(int highScore) async {
    repository.saveInt(highScoreKey, highScore);
  }

  Future<int?> getHighScore() async {
    return repository.getInt(highScoreKey);
  }
}
