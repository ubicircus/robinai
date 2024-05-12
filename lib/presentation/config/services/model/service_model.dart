import 'package:hive/hive.dart';

part 'service_model.g.dart';

@HiveType(typeId: 4)
class ServiceModel extends HiveObject {
  @HiveField(0)
  late String serviceName;

  @HiveField(1)
  late String apiKey;
}
