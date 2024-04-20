import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/chat_message_class.dart';
import '../provider/chat_provider.dart';

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';

void main() {
  initializeDateFormatting().then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        home: ChatPage(),
      );
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<types.Message> _messages = [];
  final _user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
  );

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
        } finally {
          final index =
              _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
              (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);
  }

  void _loadMessages() async {
    final response = await rootBundle.loadString('assets/messages.json');
    final messages = (jsonDecode(response) as List)
        .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
        .toList();

    setState(() {
      _messages = messages;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Chat(
          messages: _messages,
          onMessageTap: _handleMessageTap,
          onSendPressed: _handleSendPressed,
          showUserAvatars: true,
          showUserNames: true,
          user: _user,
        ),
      );
}
// class MainPage extends StatefulWidget {
//   @override
//   State<MainPage> createState() => _MainPageState();
// }

// class _MainPageState extends State<MainPage> {
//   @override
//   Widget build(BuildContext context) {
//     // Determine the screen size for responsive UI
//     final Size screenSize = MediaQuery.of(context).size;
//     final bool isMobile = screenSize.width < 600;
//     final List<ChatMessageClass> messages =
//         Provider.of<ChatProvider>(context, listen: true).messages;
//     ScrollController _scrollController = ScrollController();

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Flutter Chat'),
//         leading: IconButton(
//           icon: Icon(Icons.menu),
//           onPressed: () {
//             // Handle menu open
//           },
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () {
//               // Handle additional actions
//             },
//           ),
//           IconButton(
//             iconSize: isMobile ? 48 : 36, // Larger icon for mobile
//             icon: Icon(Icons.mic),
//             onPressed: () {
//               // Handle voice input
//             },
//           ),
//           IconButton(
//             iconSize: isMobile ? 48 : 36,
//             icon: Icon(Icons.photo_camera),
//             onPressed: () {
//               // Handle image input
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             child: ListView.builder(
//               itemCount: messages.length,
//               itemBuilder: (BuildContext context, int index) {
//                 return _buildChatMessage(
//                     messages[index], context, _scrollController);
//               },
//               controller: _scrollController,
//             ),
//           ),

//           // _buildActionButtons(screenSize),
//           _buildTextInputField(context),
//         ],
//       ),
//     );
//   }

Widget _buildChatMessage(ChatMessageClass message, BuildContext ctx,
    ScrollController _scrollController) {
  _scrollController.animateTo(_scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 3.0),
    child: Row(
      mainAxisAlignment: message.isUserMessage
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: Container(
            // width: double.infinity,
            // width: MediaQuery.of(ctx).size.width - 30,
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color:
                  message.isUserMessage ? Colors.teal[300] : Colors.grey[300],
            ),
            child: Text(
              message.content,
              style: TextStyle(
                fontSize: 16.0,
                color: message.isUserMessage ? Colors.white : Colors.black,
              ),
              // overflow: TextOverflow.clip,
              softWrap: true,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildActionButtons(Size screenSize) {
  // This can be abstracted into a separate widget if needed
  final bool isMobile = screenSize.width < 600; // Example breakpoint for mobile
  return Padding(
    padding: EdgeInsets.all(8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          iconSize: isMobile ? 48 : 36, // Larger icon for mobile
          icon: Icon(Icons.mic),
          onPressed: () {
            // Handle voice input
          },
        ),
        IconButton(
          iconSize: isMobile ? 48 : 36,
          icon: Icon(Icons.image),
          onPressed: () {
            // Handle image input
          },
        ),
      ],
    ),
  );
}

Widget _buildTextInputField(BuildContext context) {
  final TextEditingController _textController = TextEditingController();
  return Container(
    color: Colors.teal,
    // color: Colors.black26,

    padding: const EdgeInsets.only(left: 12.0, bottom: 12.0, top: 12.0),
    child: Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            // style: TextStyle(color: Colors.white),
            controller: _textController,
            decoration: InputDecoration(
              hintText: 'Type a message',
              hintStyle: TextStyle(color: Colors.teal[50]),
              border: InputBorder.none,
            ),
            onSubmitted: (String value) {
              final message = ChatMessageClass(
                id: Uuid().v1(),
                content: value,
                isUserMessage: true,
                timestamp: DateTime.now(),
              );

              Provider.of<ChatProvider>(context, listen: false)
                  .addMessage(message);
              _textController.clear();
            },
            // You can add more properties according to the usage like controllers, focus nodes, etc.
          ),
        ),
        IconButton(
          icon: Icon(Icons.send),
          onPressed: () {
            final message = ChatMessageClass(
                id: Uuid().v1(),
                content: _textController.text,
                isUserMessage: true,
                timestamp: DateTime.now());

            Provider.of<ChatProvider>(context, listen: false)
                .addMessage(message);
            _textController.clear();
          },
        ),
      ],
    ),
  );
}
