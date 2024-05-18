import 'package:robin_ai/core/service_names.dart';
import 'package:flutter/material.dart';

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
      logoAsset: 'assets/images/ce-logo.png',
      caption: 'Dyrektywa',
    ),
    ServiceName.perplexity: ServiceMetadata(
      logoAsset: 'assets/images/perplexity-logo.png',
      caption: 'Perplexity',
    ),
    ServiceName.gemini: ServiceMetadata(
      logoAsset: 'assets/images/gemini-logo.png',
      caption: 'Gemini',
    ),
  };
}

class ServiceMetadata {
  final String logoAsset;
  final String caption;

  const ServiceMetadata({required this.logoAsset, required this.caption});
}

class AppColors {
  static const Color lightSage = Color(0xFFD8E2DC);
  static const Color paleSpringBud = Color(0xFFE3F2E1);
  static const Color teaGreen = Color(0xFFD4E2D4);
}
