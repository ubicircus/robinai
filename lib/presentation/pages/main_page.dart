import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/chat_message_class.dart';
import '../provider/chat_provider.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Determine the screen size for responsive UI
    final Size screenSize = MediaQuery.of(context).size;
    final bool isMobile = screenSize.width < 600;
    final List<ChatMessageClass> messages =
        Provider.of<ChatProvider>(context, listen: true).messages;

    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Chat'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            // Handle menu open
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Handle additional actions
            },
          ),
          IconButton(
            iconSize: isMobile ? 48 : 36, // Larger icon for mobile
            icon: Icon(Icons.mic),
            onPressed: () {
              // Handle voice input
            },
          ),
          IconButton(
            iconSize: isMobile ? 48 : 36,
            icon: Icon(Icons.photo_camera),
            onPressed: () {
              // Handle image input
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (BuildContext context, int index) {
                return _buildChatMessage(messages[index]);
              },
            ),
          ),

          // _buildActionButtons(screenSize),
          _buildTextInputField(context),
        ],
      ),
    );
  }

  Widget _buildChatMessage(ChatMessageClass message) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: message.isUserMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color:
                  message.isUserMessage ? Colors.teal[300] : Colors.grey[300],
            ),
            child: Text(message.content, style: TextStyle(fontSize: 16.0)),
          )
        ],
      ),
    );
  }

  Widget _buildActionButtons(Size screenSize) {
    // This can be abstracted into a separate widget if needed
    final bool isMobile =
        screenSize.width < 600; // Example breakpoint for mobile
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
}
