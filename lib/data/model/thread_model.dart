import 'package:hive/hive.dart';

part 'thread_model.g.dart'; // Hive will generate this for you.

@HiveType(typeId: 2)
class Thread extends HiveObject {
  @HiveField(0)
  final String id; // UUID for the thread

  @HiveField(1)
  final String name; // Human-readable name for the thread

  Thread({required this.id, required this.name});
}
