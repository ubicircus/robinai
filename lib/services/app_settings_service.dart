import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/model/service_model.dart';

class AppSettingsService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const _boxName = 'encryptedBox';

  Future<void> initAppSettings() async {
    await _openEncryptedBox();
    // await readApiKeys();
  }

  Future<Box> _openEncryptedBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      final encryptionKeyEncoded =
          await _secureStorage.read(key: 'encryptionKey');
      final encryptionKey = encryptionKeyEncoded != null
          ? base64Url.decode(encryptionKeyEncoded)
          : Hive.generateSecureKey();

      if (encryptionKeyEncoded == null) {
        // Store the new encryption key in secure storage
        final encryptionKeyEncodedToSave = base64Url.encode(encryptionKey);
        await _secureStorage.write(
            key: 'encryptionKey', value: encryptionKeyEncodedToSave);
      }

      final box = await Hive.openBox(_boxName,
          encryptionCipher: HiveAesCipher(encryptionKey));
      return box;
    } else {
      return Hive.box(_boxName);
    }
  }

  Future<Map<String, String>> readApiKeys() async {
    final box = await _openEncryptedBox();
    // Initialize default ServiceModel in case the keys don't exist
    ServiceModel defaultServiceModel = ServiceModel()
      ..serviceName = ''
      ..apiKey = '';

    // Fetch the ServiceModel instances or use defaults
    ServiceModel openAIRecord =
        box.get('openAI', defaultValue: defaultServiceModel);
    ServiceModel groqRecord =
        box.get('groq', defaultValue: defaultServiceModel);

    return {
      'openAI': openAIRecord.apiKey,
      'groq': groqRecord.apiKey,
    };
  }

  String? getOpenAIKey() {
    if (Hive.isBoxOpen(_boxName)) {
      final box = Hive.box(_boxName);
      final openAIRecord = box.get('openAI') as ServiceModel?;
      return openAIRecord?.apiKey;
    }
    return null;
  }

  Future<void> updateOpenAIKey(String key) async {
    final box = await _openEncryptedBox();
    final openAIRecordExists = box.containsKey('openAI');

    if (openAIRecordExists) {
      final openAIRecord = box.get('openAI') as ServiceModel;
      openAIRecord.apiKey = key;
      await box.put('openAI', openAIRecord); // Updated this line
      print("OpenAI API Key updated: $key");
    } else {
      final openAIRecord = ServiceModel()
        ..serviceName = 'OpenAI'
        ..apiKey = key;
      await box.put('openAI', openAIRecord); // Updated this line
      print("OpenAI API Key created: $key");
    }
  }

  Future<void> updateGroqKey(String key) async {
    final box = await _openEncryptedBox();
    final groqRecordExists = box.containsKey('groq');

    if (groqRecordExists) {
      final groqRecord = box.get('groq') as ServiceModel;
      groqRecord.apiKey = key;
      await groqRecord.save();
      print("Groq API Key updated: $key");
    } else {
      final groqRecord = ServiceModel()
        ..serviceName = 'Groq'
        ..apiKey = key;
      await groqRecord.save();
      print("Groq API Key created: $key");
    }
  }

  Future<void> closeBox() async {
    await Hive.box('encryptedBox').close();
  }
}
