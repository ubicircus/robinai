import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:robin_ai/data/model/thread_model.dart';

import 'package:robin_ai/domain/entities/exceptions.dart';

class ChatLocalDataSource {
  final String _threadBoxName = "threads";
  late Box<ThreadModel> _threadBox;
  bool _isInitialized = false;

  ChatLocalDataSource() {
    initialize();
  }

  bool get isInitialized => _isInitialized && _threadBox.isOpen;

  Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      Hive.init(appDir.path);

      _threadBox = await Hive.openBox<ThreadModel>(_threadBoxName);
      _isInitialized = true;
    } catch (e) {
      print('Error initializing thread box: $e');
      throw InitializationException(
          details: 'Failed to initialize $_threadBoxName due to $e');
    }
  }

  Future<void> addThread(ThreadModel thread) async {
    if (!_isInitialized) {
      throw InitializationException();
    }
    try {
      await _threadBox.put(thread.id, thread);
    } catch (e) {
      print('Error adding thread: $e');
      rethrow;
    }
  }

  Future<void> addMessageToThread(String threadId, Message message) async {
    if (!_isInitialized) {
      throw InitializationException();
    }
    try {
      var _thread = _threadBox.get(threadId);

      if (_thread != null) {
        ThreadModel thread = _thread;
        // thread.messages ??= []; // initialize messages list if it's null
        thread.messages.insert(0, message);
        await _threadBox.put(threadId, thread);
      } else {
        await createThread(threadId,
            message); // invoke createThread function with the threadId and new message
      }
    } catch (e) {
      print('Error adding message to thread: $e');
      rethrow;
    }
  }

  List<Message> getAllMessagesFromThread(String threadId) {
    if (!_isInitialized) {
      throw InitializationException();
    }
    try {
      ThreadModel thread = _threadBox.get(threadId) as ThreadModel;
      if (thread != null) {
        return thread.messages;
      } else {
        throw FetchDataException(); // Thread not found
      }
    } catch (e) {
      print('Error retrieving messages from thread: $e');
      throw FetchDataException();
    }
  }

  List<ThreadModel> getAllThreads() {
    if (!_isInitialized) {
      throw InitializationException();
    }
    try {
      return _threadBox.values.toList().cast<ThreadModel>();
    } catch (e) {
      print('Error retrieving threads: $e');
      throw FetchDataException();
    }
  }

  Future<void> closeBox() async {
    if (!_isInitialized) {
      throw InitializationException();
    }
    try {
      await _threadBox.close();
      _isInitialized = false;
      print('Thread box closed successfully.');
    } catch (e) {
      print('Error closing thread box: $e');
      throw CloseDataException();
    }
  }

  ThreadModel? getThreadById(String threadId) {
    if (!_isInitialized) {
      throw InitializationException();
    }
    try {
      return _threadBox.get(threadId);
    } catch (e) {
      print('Error retrieving thread by ID: $e');
      throw FetchDataException();
    }
  }

  // Future<void> updateThreadName(String threadId, String newName) async {
  //   if (!_isInitialized) {
  //     throw InitializationException();
  //   }
  //   try {
  //     ThreadModel? threadToUpdate = _threadBox.get(threadId);
  //     if (threadToUpdate != null) {
  //       threadToUpdate.name = newName;
  //       await threadToUpdate.save();
  //     }
  //   } catch (e) {
  //     print('Error updating thread name: $e');
  //     rethrow;
  //     // throw UpdateDataException(); //todo
  //   }
  // }

  Future<void> createThread(String threadId, Message message) async {
    try {
      ThreadModel thread =
          ThreadModel(id: threadId, messages: [message], name: 'New Chat');
      await _threadBox.put(threadId, thread);
    } catch (e) {
      print('Error creating thread: $e');
      rethrow;
    }
  }

  Future<void> deleteThread(String threadId) async {
    if (!_isInitialized) {
      throw InitializationException();
    }
    try {
      await _threadBox.delete(threadId);
      // Assuming you need to also delete associated messages
      // Additional logic needed based on your application requirements
    } catch (e) {
      print('Error deleting thread and associated messages: $e');
      rethrow;
      // throw DeleteDataException(); // todo
    }
  }
}
