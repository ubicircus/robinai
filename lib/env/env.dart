// lib/env/env.dart
import 'package:envied/envied.dart';
part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(
      varName: 'OPEN_AI_API_KEY', obfuscate: true) // the .env variable.
  static final String openAIKey = _Env.openAIKey;
}
