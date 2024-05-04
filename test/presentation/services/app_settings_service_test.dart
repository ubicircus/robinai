import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:robin_ai/services/app_settings_service.dart';

void main() {
  test('Test AppSettingsService', () async {
    await Hive.initFlutter();

    final appSettingsService = AppSettingsService();

    await appSettingsService.initAppSettings();

    // Test updateOpenAIKey
    await appSettingsService.updateOpenAIKey('openAIKey');
    expect(appSettingsService.getOpenAIKey(), 'openAIKey');

    // Test updateGroqKey
    await appSettingsService.updateGroqKey('groqKey');
    expect(appSettingsService.getGroqKey(), 'groqKey');

    // Test readApiKeys
    final apiKeys = await appSettingsService.readApiKeys();
    expect(apiKeys, {'openAI': 'openAIKey', 'groq': 'groqKey'});

    // Test closeBox
    await appSettingsService.closeBox();
  });
}
