import 'package:robin_ai/core/service_names.dart';
import 'package:robin_ai/data/repository/models_repository.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';
import '../../../../core/error_messages.dart';

class GetModelsUseCase {
  final ModelsRepository modelsRepository;

  GetModelsUseCase({required this.modelsRepository});

  Future<List<String>> call(
    ServiceName serviceName,
  ) async {
    try {
      final modelsAvailable =
          await modelsRepository.getModels(serviceName: serviceName);
      return modelsAvailable;
    } catch (e) {
      // Log the error or handle it appropriately
      print('Error sending message: $e');
      throw Exception(ErrorMessages.sendMessageFailed);
    }
  }
}
