import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:robin_ai/presentation/bloc/chat_bloc.dart';

class ModelsPopupMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<ChatBloc>().state;
    return GestureDetector(
      onTap: () => _showCupertinoModelsMenu(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            state.modelName.isEmpty ? 'Select Model' : state.modelName,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.fade,
          ),

          SizedBox(width: 5), // Space between text and icon
          Icon(
            CupertinoIcons.right_chevron,
            size: 16,
          ),
        ],
      ),
    );
  }

  void _showCupertinoModelsMenu(BuildContext context) {
    final state = context.read<ChatBloc>().state;
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Select Model'),
        actions: state.modelsAvailable.map((model) {
          return CupertinoActionSheetAction(
            child: Text(model),
            onPressed: () {
              context.read<ChatBloc>().add(SelectModelEvent(modelName: model));
              Navigator.pop(context);
            },
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
