import 'package:robin_ai/core/service_names.dart';
import 'package:robin_ai/data/datasources/llm_models/ModelInterface.dart';

abstract class ModelFactoryInterface {
  ModelInterface getService(ServiceName serviceName);
  ModelInterface getModels(ServiceName serviceName);
}
