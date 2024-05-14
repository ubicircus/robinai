import 'dart:developer';

import 'package:robin_ai/core/service_names.dart';
import 'package:robin_ai/data/datasources/llm_models/ModelInterface.dart';
import 'package:robin_ai/data/datasources/llm_models/ModelFactoryInterface.dart';
import 'package:robin_ai/data/datasources/llm_models/dyrektywa/machinery_directive_model.dart';
import 'package:robin_ai/data/datasources/llm_models/groq/groq_model.dart';
import 'package:robin_ai/data/datasources/llm_models/openai/openai_model.dart';
import 'package:robin_ai/data/datasources/llm_models/perplexity/perplexity_model.dart';

class ModelFactory implements ModelFactoryInterface {
  @override
  ModelInterface getService(ServiceName serviceName) {
    if (serviceName == ServiceName.openai) {
      return OpenAIModel();
    } else if (serviceName == ServiceName.groq) {
      return GroqModel();
    } else if (serviceName == ServiceName.dyrektywa) {
      return DyrektywaModel();
    } else if (serviceName == ServiceName.perplexity) {
      return PerplexityModel();
    } else {
      throw Exception('Unsupported service name: $serviceName');
    }
  }

  @override
  ModelInterface getModels(ServiceName serviceName) {
    if (serviceName == ServiceName.openai) {
      return OpenAIModel();
    } else if (serviceName == ServiceName.groq) {
      return GroqModel();
    } else if (serviceName == ServiceName.dyrektywa) {
      return DyrektywaModel();
    } else if (serviceName == ServiceName.perplexity) {
      return PerplexityModel();
    } else {
      throw Exception('Unsupported service name: $serviceName');
    }
  }
}
