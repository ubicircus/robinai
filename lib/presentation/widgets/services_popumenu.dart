import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:robin_ai/core/constants.dart';
import 'package:robin_ai/core/service_names.dart';
import 'package:robin_ai/presentation/bloc/chat_bloc.dart';

class ServicesPopupMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ServiceName serviceName = context.watch<ChatBloc>().state.serviceName;
    ServiceMetadata? serviceMetadata =
        AppConstants.serviceMetadata[serviceName];

    return GestureDetector(
      onTap: () => _showCupertinoServicesMenu(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (serviceMetadata != null)
            Flexible(
              child: Container(
                width: 80, // adjust the width
                // height: 20, // adjust the height
                child: Image.asset(serviceMetadata.logoAsset),
              ),
            ),
          // if (serviceMetadata != null)
          //   Flexible(
          //     child: Text(
          //       serviceMetadata.caption,
          //       style: const TextStyle(
          //           // color: CupertinoColors.activeBlue, // Makes the text look tappable
          //           // fontWeight: FontWeight.bold,
          //           ),
          //     ),
          //   ),
          SizedBox(width: 5), // Space between text and icon
          Icon(
            CupertinoIcons.right_chevron,
            // color: CupertinoColors.activeBlue,
            size: 16,
          ),
        ],
      ),
    );
  }
}

void _showCupertinoServicesMenu(BuildContext context) {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      title: const Text('Select Service'),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: const Text('OpenAI'),
          onPressed: () {
            context.read<ChatBloc>().add(
                SelectServiceProviderEvent(serviceName: ServiceName.openai));
            Navigator.pop(context);
          },
        ),
        CupertinoActionSheetAction(
          child: const Text('Groq'),
          onPressed: () {
            context
                .read<ChatBloc>()
                .add(SelectServiceProviderEvent(serviceName: ServiceName.groq));
            Navigator.pop(context);
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: const Text('Cancel'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ),
  );
}
