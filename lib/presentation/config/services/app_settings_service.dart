import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:robin_ai/core/service_names.dart';
import '../services/model/service_model.dart';

class AppSettingsService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const _boxName = 'encryptedBox';
  // static final List<String> _services = [
  //   'openai',
  //   'groq'
  // ]; // Add more services here

  Future<void> initAppSettings() async {
    await _openEncryptedBox();
    // Initialize keys as needed or other start-up tasks
  }

  Future<Box> _openEncryptedBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      final encryptionKeyEncoded =
          await _secureStorage.read(key: 'encryptionKey');
      final encryptionKey = encryptionKeyEncoded != null
          ? base64Url.decode(encryptionKeyEncoded)
          : Hive.generateSecureKey();

      if (encryptionKeyEncoded == null) {
        final encryptionKeyEncodedToSave = base64Url.encode(encryptionKey);
        await _secureStorage.write(
            key: 'encryptionKey', value: encryptionKeyEncodedToSave);
      }

      return await Hive.openBox(_boxName,
          encryptionCipher: HiveAesCipher(encryptionKey));
    } else {
      return Hive.box(_boxName);
    }
  }

  Future<Map<String, String>> readApiKeys() async {
    final box = await _openEncryptedBox();
    Map<String, String> apiKeys = {};

    for (ServiceName service in ServiceName.values) {
      String key = service.name;
      ServiceModel record = box.get(key,
          defaultValue: ServiceModel()
            ..serviceName = key
            ..apiKey = '');
      apiKeys[key] = record.apiKey;
    }

    return apiKeys;
  }

  Future<void> updateApiKey(String serviceName, String apiKey) async {
    final box = await _openEncryptedBox();
    ServiceModel serviceModel = box.get(serviceName,
        defaultValue: ServiceModel()..serviceName = serviceName);
    serviceModel.apiKey = apiKey;
    await box.put(serviceName, serviceModel);

    print("$serviceName API Key updated: $apiKey");
  }

  Future<void> closeBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      await Hive.box(_boxName).close();
      print("Box $_boxName closed successfully.");
    }
  }
}
