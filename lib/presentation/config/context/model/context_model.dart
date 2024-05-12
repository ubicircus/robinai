import 'package:hive/hive.dart';

part 'context_model.g.dart';

@HiveType(typeId: 5)
class ContextModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String text;

  @HiveField(3)
  String formatSpecifier = '';

  @HiveField(4)
  String actionUrl = '';

  @HiveField(5)
  bool isActionActive = false;

  @HiveField(6)
  bool isContextActive = true;

  @HiveField(7)
  bool isDefault = false;

  ContextModel({
    required this.id,
    required this.name,
    required this.text,
    required this.formatSpecifier,
    required this.actionUrl,
    required this.isActionActive,
    required this.isContextActive,
    required this.isDefault,
  });
}
