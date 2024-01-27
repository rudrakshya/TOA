import 'package:hive/hive.dart';

class TokenStorage {
  static const String _boxName = 'tokenBox';
  Box<String>? _box;

  TokenStorage() {
    _openBox();
  }

  Future<void> _openBox() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  Future<void> addNewItem(String keyName, String keyValue) async {
    await _ensureBoxInitialized();
    _box?.put(keyName, keyValue);
  }

  Future<String> readByKey(String keyName) async {
    await _ensureBoxInitialized();
    // print(keyName);
    var keyValue = _box?.get(keyName);
    return keyValue.toString();
  }

  Future<void> deleteByKey(String keyName) async {
    await _ensureBoxInitialized();
    await _box?.delete(keyName);
  }

  Future<void> deleteAll() async {
    await _ensureBoxInitialized();
    await _box!.clear();
  }

  Future<void> closeBox() async {
    await _box?.close();
  }

  Future<void> _ensureBoxInitialized() async {
    if (_box == null || !_box!.isOpen) {
      await _openBox();
    }
  }
}
