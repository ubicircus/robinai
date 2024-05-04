import 'package:robin_ai/core/service_names.dart';
import 'package:robin_ai/data/datasources/chat_network.dart';
import 'package:robin_ai/domain/interfaces/models_repository_interface.dart';

class ModelsRepository implements IModelsRepositoryInterface {
  final ChatNetworkDataSource chatNetworkDataSource;

  ModelsRepository({required this.chatNetworkDataSource});

  @override
  Future<List<String>> getModels({required ServiceName serviceName}) async {
    try {
      Future<List<String>> modelsAvailable =
          chatNetworkDataSource.getModels(serviceName: serviceName);
      return modelsAvailable;
    } catch (e) {
      throw UnimplementedError();
    }
  }
}
