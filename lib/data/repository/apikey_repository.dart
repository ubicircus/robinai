class ApiKeyRepository {
  Box<ApiKey> apiKeyBox;

  ApiKeyRepository(this.apiKeyBox);

  Future<void> addApiKey(String serviceName, String key) async {
    final apiKey = ApiKey(serviceName: serviceName, key: key);
    await apiKeyBox.add(apiKey);
  }

  List<ApiKey> getAllApiKeys() {
    return apiKeyBox.values.toList();
  }

  Future<void> removeApiKey(int index) async {
    await apiKeyBox.deleteAt(index);
  }
}


  // var encryptionKey = base64Url.decode(await secureStorage.read(key: 'encryptionKey'));

  // var encryptedBox = await Hive.openBox('encryptedBox', encryptionCipher: HiveAesCipher(encryptionKey));
  // encryptedBox.put('secret', 'Hive is awesome');
  // print(encryptedBox.get('secret'));