import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:uuid/uuid.dart';

import '../../env/env.dart';
import '../../domain/entities/chat_message_class.dart';

class ChatNetworkDataSource {
  var uuid = Uuid();

  // POST request to send a message
  Future<ChatMessageClass> sendChatMessage(ChatMessageClass message) async {
    final response = await askLLM(message.content);

    // return the correct type - ChatMessage
    return ChatMessageClass(
        id: uuid.v1(),
        content: response,
        isUserMessage: false,
        timestamp: DateTime.now());
  }
}

Future<dynamic> askLLM(String input) async {
  final model = ChatOpenAI(
    apiKey: Env.openAIKey,
    model: 'gpt-3.5-turbo-0613',
  );

  //the system prompt should be injected here according to the ceontext or the history
  final promptTemplate = SystemChatMessagePromptTemplate.fromTemplate(
      '''You are a helpful assistant.
''');
  final humanTemplate = HumanChatMessagePromptTemplate.fromTemplate('{text}');
  final chatPrompt = ChatPromptTemplate.fromPromptMessages([
    promptTemplate,
    humanTemplate,
  ]);

  const stringOutputParser = StringOutputParser();
  final chain = Runnable.fromList([chatPrompt, model, stringOutputParser]);

  var result = await chain.invoke({'text': input});
  //utf8.decode(taskOutput.runes.toList()),

  return result;
}



  // // GET request to fetch all messages
  // Future<List<ChatMessage>> fetchAllMessages() async {
  //   final response = await http.get(Uri.parse('$_baseUrl/messages'));

  //   if (response.statusCode == 200) {
  //     List<dynamic> jsonMessages = jsonDecode(response.body);
  //     List<ChatMessage> chatMessages = jsonMessages.map((jsonMsg) {
  //       return ChatMessage(
  //           content: jsonMsg['message'],
  //           isUserMessage: jsonMsg['isUser'] == 'true',
  //           id: jsonMsg['uuid'],
  //           timestamp: jsonMsg['timestamp']
  //           // Parse other fields as necessary
  //           );
  //     }).toList();

  //     return chatMessages;
  //   } else {
  //     throw Exception('Failed to load messages');
  //   }
  // }