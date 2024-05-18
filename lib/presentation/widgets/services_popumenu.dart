import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:robin_ai/core/constants.dart';
import 'package:robin_ai/core/service_names.dart';
import 'package:robin_ai/presentation/bloc/chat_bloc.dart';
import 'package:robin_ai/presentation/config/services/app_settings_service.dart';

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
                height: 30, // adjust the height
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

void _showCupertinoServicesMenu(BuildContext context) async {
  AppSettingsService appSettingsService = AppSettingsService();
  Map<String, String> apiKeys = await appSettingsService.readApiKeys();

  List<CupertinoActionSheetAction> actions = [];
  bool hasApiKey = false;

  for (ServiceName serviceName in ServiceName.values) {
    if (apiKeys[serviceName.name]!.isNotEmpty) {
      hasApiKey = true;
      switch (serviceName) {
        case ServiceName.openai:
          actions.add(
            CupertinoActionSheetAction(
              child: const Text('OpenAI'),
              onPressed: () {
                context.read<ChatBloc>().add(SelectServiceProviderEvent(
                    serviceName: ServiceName.openai));
                Navigator.pop(context);
              },
            ),
          );
          break;
        case ServiceName.groq:
          actions.add(
            CupertinoActionSheetAction(
              child: const Text('Groq'),
              onPressed: () {
                context.read<ChatBloc>().add(
                    SelectServiceProviderEvent(serviceName: ServiceName.groq));
                Navigator.pop(context);
              },
            ),
          );
          break;
        case ServiceName.perplexity:
          actions.add(
            CupertinoActionSheetAction(
              child: const Text('Perplexity'),
              onPressed: () {
                context.read<ChatBloc>().add(SelectServiceProviderEvent(
                    serviceName: ServiceName.perplexity));
                Navigator.pop(context);
              },
            ),
          );
          break;
        case ServiceName.gemini:
          actions.add(
            CupertinoActionSheetAction(
              child: const Text('Gemini'),
              onPressed: () {
                context.read<ChatBloc>().add(SelectServiceProviderEvent(
                    serviceName: ServiceName.gemini));
                Navigator.pop(context);
              },
            ),
          );
          break;
        case ServiceName.dyrektywa:
          actions.add(
            CupertinoActionSheetAction(
              child: const Text('Dyrektywa'),
              onPressed: () {
                context.read<ChatBloc>().add(SelectServiceProviderEvent(
                    serviceName: ServiceName.dyrektywa));
                Navigator.pop(context);
              },
            ),
          );
          break;
      }
    }
  }

  if (!hasApiKey) {
    actions.add(
      CupertinoActionSheetAction(
        child: const Text('Please enter at least one API key'),
        onPressed: () {},
      ),
    );
  }

  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      title: const Text('Select Service'),
      actions: actions,
      cancelButton: CupertinoActionSheetAction(
        child: const Text('Cancel'),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ),
  );
}
