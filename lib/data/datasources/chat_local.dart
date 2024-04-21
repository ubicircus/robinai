import 'package:hive/hive.dart';
import 'package:robin_ai/domain/entities/chat_message_class.dart';

class ChatLocalDataSource {
  final String _boxName = "chat_history_box";

  Future<Box> openChatBox() async {
    return await Hive.openBox<ChatMessage>(_boxName);
  }

  Future<void> addChatMessage(ChatMessage chatMessage) async {
    var box = await openChatBox();
    await box.add(chatMessage);
    // When done with a box, close it.
    await box.close();
  }

  Future<List<ChatMessage>> getChatMessages() async {
    var box = await openChatBox();
    List<ChatMessage> messages = box.values.toList().cast<ChatMessage>();
    // When done with a box, close it.
    await box.close();
    return messages;
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
}
