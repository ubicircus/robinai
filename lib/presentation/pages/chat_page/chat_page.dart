import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:robin_ai/core/constants.dart';
import 'package:robin_ai/core/service_names.dart';
import 'package:robin_ai/presentation/bloc/chat_bloc.dart';
import 'package:robin_ai/presentation/config/context/app_settings_context_config.dart';
import 'package:robin_ai/presentation/config/services/app_settings_service.dart';
import 'package:robin_ai/presentation/pages/chat_page/chat_page_chat_widget.dart';
import 'package:robin_ai/presentation/pages/chat_page/chat_page_drawer.dart';
import 'package:robin_ai/presentation/widgets/api_key_notice.dart';
import 'package:robin_ai/presentation/widgets/models_popupmenu.dart';
import 'package:robin_ai/presentation/widgets/services_popumenu.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Future<Map<String, String>>? _apiKeysFuture;

  @override
  void initState() {
    super.initState();
    _loadApiKeys();
  }

  void _loadApiKeys() {
    setState(() {
      _apiKeysFuture = AppSettingsService().readApiKeys();
    });
  }

  void _refreshApiKeys() {
    _loadApiKeys();
  }

  @override
  void didChangeDependencies() {
    _loadApiKeys();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: AppColors.lightSage,
        title: FutureBuilder<Map<String, String>>(
          future: _apiKeysFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              Map<String, String> apiKeys = snapshot.data!;
              bool hasApiKey = _hasApiKey(apiKeys);
              return hasApiKey
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ServicesPopupMenu(),
                        const SizedBox(height: 15),
                        ModelsPopupMenu(),
                      ],
                    )
                  : Center(child: ApiKeyNotice());
            } else {
              return const Center(child: Text('Enter API Key'));
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore_page_outlined, size: 36),
            onPressed: () {
              context.read<ChatBloc>().add(ClearChatEvent());
            },
          )
        ],
      ),
      drawer: DrawerChatPage(onSettingsUpdated: _refreshApiKeys),
      body: ChatPageChatWidget(),
    );
  }

  bool _hasApiKey(Map<String, String> apiKeys) {
    for (ServiceName serviceName in ServiceName.values) {
      if (apiKeys[serviceName.name] != null &&
          apiKeys[serviceName.name]!.isNotEmpty) {
        return true;
      }
    }
    return false;
  }
}
