import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:robin_ai/data/model/chat_message_local_model.dart';

import 'package:robin_ai/domain/entities/exceptions.dart';

class ChatLocalDataSource {
  final String _boxName = "chatHistory";
  late Box<ChatMessageLocal> _chatBox;
  bool _isInitialized = false;

  ChatLocalDataSource() {
    initialize();
  }

  bool get isInitialized => _isInitialized && _chatBox.isOpen;

  Future<void> initialize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      Hive.init(appDir.path);

      // Check if box is already open to prevent multiple open instances
      if (Hive.isBoxOpen(_boxName)) {
        _chatBox = Hive.box<ChatMessageLocal>(_boxName);
        print('Using already opened chat box.');
      } else {
        _chatBox = await Hive.openBox<ChatMessageLocal>(_boxName);
        print('Chat box initialized!');
      }

      _isInitialized = true;
    } catch (e) {
      print('Error initializing chat box: $e');
      throw InitializationException(
          details: 'Failed to initialize $_boxName due to $e');
    }
  }

  Future<void> addChatMessageLocal(ChatMessageLocal ChatMessageLocal) async {
    if (!_isInitialized) {
      throw InitializationException();
    }
    try {
      await _chatBox.add(ChatMessageLocal);
    } catch (e) {
      print('Error adding chat message: $e');
      rethrow;
    }
  }

  List<ChatMessageLocal> getChatMessagesLocal() {
    if (!_isInitialized) {
      throw InitializationException();
    }
    try {
      return _chatBox.values.toList().cast<ChatMessageLocal>();
    } catch (e) {
      print('Error retrieving chat messages: $e');
      throw FetchDataException();
    }
  }

  Future<void> closeBox() async {
    if (!_isInitialized) {
      throw InitializationException();
    }
    try {
      await _chatBox.close();
      _isInitialized = false;
      print('Chat box closed successfully.');
    } catch (e) {
      print('Error closing chat box: $e');
      throw CloseDataException();
    }
  }
}

  // If you need to implement message deletion or updating
  // you can add those methods here as well.

//   Box<Thread> threadBox = Hive.box<Thread>('threads');

// // Adding a new thread
// String threadId = UUID().v4(); // Generate a UUID for the new thread
// await threadBox.put(threadId, Thread(id: threadId, name: 'Thread Name'));

// // Retrieving a thread by ID
// Thread? thread = threadBox.get(threadId);

// // Getting all threads (e.g., for displaying in UI)
// List<Thread> allThreads = threadBox.values.toList();

// // Renaming a thread
// Thread? threadToRename = threadBox.get(threadId);
// if (threadToRename != null) {
//   threadToRename.name = 'New Thread Name';
//   threadToRename.save();
// }

// // Deleting a thread and its messages
// await threadBox.delete(threadId);
// You would also need to delete all messages associated with this thread ID

