import 'dart:async';
import 'package:robin_ai/core/service_names.dart';

abstract class IModelsRepositoryInterface {
  Future<List<String>> getModels({
    required ServiceName serviceName,
  });
}
