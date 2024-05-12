import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:robin_ai/core/constants.dart';
import 'package:robin_ai/presentation/bloc/chat_bloc.dart';
import 'package:robin_ai/presentation/config/context/app_settings_context_config.dart';
import 'package:robin_ai/presentation/config/context/model/context_model.dart';

class ContextListPage extends StatefulWidget {
  @override
  _ContextListPageState createState() => _ContextListPageState();
}

class _ContextListPageState extends State<ContextListPage> {
  final ContextModelService _contextModelService = ContextModelService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contexts'),
        backgroundColor: AppColors.lightSage,
      ),
      backgroundColor: AppColors.lightSage,
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          // Accessing Hive data directly
          var contexts = _contextModelService.listAllContextModels();
          if (contexts.isEmpty) {
            return Center(child: Text('No Contexts Found'));
          }
          return ListView.separated(
            itemCount: contexts.length,
            itemBuilder: (context, index) {
              ContextModel contextModel = contexts[index];
              // Update UI based on Bloc state
              bool isDefault = state.context.id ==
                  contextModel.id; // Adjust according to your state management
              return ListTile(
                leading: isDefault ? Icon(Icons.check_circle_outline) : null,
                title: Text(contextModel.name),
                subtitle: Text(contextModel.text),
                tileColor: isDefault ? Colors.lightGreen[100] : null,
                onTap: () {
                  // Dispatch Bloc event
                  context
                      .read<ChatBloc>()
                      .add(SelectDefaultContext(context: contextModel));
                },
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showEditDialog(context, contextModel),
                ),
              );
            },
            separatorBuilder: (context, index) => Divider(color: Colors.grey),
          );
        },
      ),
    );
  }

  Future<void> _showEditDialog(
      BuildContext context, ContextModel contextModel) async {
    final TextEditingController _nameController =
        TextEditingController(text: contextModel.name);
    final TextEditingController _textController =
        TextEditingController(text: contextModel.text);
    final TextEditingController _formatSpecifierController =
        TextEditingController(text: contextModel.formatSpecifier);
    final TextEditingController _actionUrlController =
        TextEditingController(text: contextModel.actionUrl);
    bool _isActionActive = contextModel.isActionActive;
    bool _isContextActive = contextModel.isContextActive;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Context'),
          content: SingleChildScrollView(
            // Use SingleChildScrollView to avoid overflow
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _textController,
                  decoration: InputDecoration(labelText: 'Text'),
                ),
                TextField(
                  controller: _formatSpecifierController,
                  decoration: InputDecoration(labelText: 'Format Specifier'),
                ),
                TextField(
                  controller: _actionUrlController,
                  decoration: InputDecoration(labelText: 'Action URL'),
                ),
                SwitchListTile(
                  title: Text('Is Action Active'),
                  value: _isActionActive,
                  onChanged: (bool value) {
                    _isActionActive = value;
                  },
                ),
                SwitchListTile(
                  title: Text('Is Context Active'),
                  value: _isContextActive,
                  onChanged: (bool value) {
                    _isContextActive = value;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Save'),
              onPressed: () {
                contextModel.name = _nameController.text;
                contextModel.text = _textController.text;
                contextModel.formatSpecifier = _formatSpecifierController.text;
                contextModel.actionUrl = _actionUrlController.text;
                contextModel.isActionActive = _isActionActive;
                contextModel.isContextActive = _isContextActive;
                contextModel.save();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
