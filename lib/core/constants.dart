import 'package:robin_ai/core/service_names.dart';

class AppConstants {
  static const Map<ServiceName, ServiceMetadata> serviceMetadata = {
    ServiceName.openai: ServiceMetadata(
      logoAsset: 'assets/images/openai-logo.png',
      caption: 'OpenAI',
    ),
    ServiceName.groq: ServiceMetadata(
      logoAsset: 'assets/images/groq-logo.png',
      caption: 'Groq',
    ),
    ServiceName.dyrektywa: ServiceMetadata(
      logoAsset: 'assets/images/dyr-logo.png',
      caption: 'Dyrektywa',
    ),
  };
}

class ServiceMetadata {
  final String logoAsset;
  final String caption;

  const ServiceMetadata({required this.logoAsset, required this.caption});
}
