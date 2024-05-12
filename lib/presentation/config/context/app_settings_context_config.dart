import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:robin_ai/domain/entities/exceptions.dart';
import 'package:robin_ai/presentation/config/context/context_examples.dart';
import 'package:robin_ai/presentation/config/context/model/context_model.dart';

class ContextModelService {
  static final ContextModelService _instance = ContextModelService._internal();
  factory ContextModelService() => _instance;
  ContextModelService._internal();

  final String _boxName = 'contextModelBox';
  late Box<ContextModel> _box;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized && _box.isOpen;

  Future<void> initContextModelService() async {
    try {
      _box = await Hive.openBox<ContextModel>(_boxName);

      if (_box.isEmpty) {
        print('Box is empty');
        addPromptsToHive(prompts);
      }
      _isInitialized = true;
    } catch (e) {
      print('Error initializing context model box: $e');
      throw InitializationException(
          details: 'Failed to initialize $_boxName due to $e');
    }
  }

  Future<void> addContextModel(ContextModel model) async {
    if (!_isInitialized) {
      throw InitializationException();
    }
    try {
      await _box.put(model.id, model);
    } catch (e) {
      print('Error adding context model: $e');
      rethrow;
    }
  }

  Future<void> updateContextModel(String id, ContextModel updatedModel) async {
    if (!_isInitialized) {
      throw InitializationException();
    }
    try {
      await _box.put(id, updatedModel);
    } catch (e) {
      print('Error updating context model: $e');
      rethrow;
    }
  }

  List<ContextModel> listAllContextModels() {
    if (!isInitialized) {
      throw InitializationException();
    }
    try {
      return _box.values.toList().cast<ContextModel>();
    } catch (e) {
      print('Error listing all context models: $e');
      throw FetchDataException();
    }
  }

  Future<void> deleteContextModel(String id) async {
    if (!_isInitialized) {
      throw InitializationException();
    }
    try {
      await _box.delete(id);
    } catch (e) {
      print('Error deleting context model: $e');
      rethrow;
    }
  }

//only temporary for dev purpose
  Future<void> clearHiveBox() async {
    await _box.clear(); // This deletes all data in the box.
  }

//only temporary for dev purpose
  Future<void> updateContextModels() async {
    for (int i = 0; i < _box.length; i++) {
      final contextModel = _box.getAt(i);
      if (contextModel != null && contextModel.isDefault == null) {
        // Assuming you've made isDefault nullable for this operation
        contextModel.isDefault = false; // Set a default value
        await _box.putAt(i, contextModel); // Update the entry in the box
      }
    }
  }

  Future<void> closeBox() async {
    if (!_isInitialized) {
      throw InitializationException();
    }
    try {
      await _box.close();
      _isInitialized = false;
      print('Context model box closed successfully.');
    } catch (e) {
      print('Error closing context model box: $e');
      throw CloseDataException();
    }
  }
}
