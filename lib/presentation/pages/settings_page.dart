import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:robin_ai/core/service_names.dart';
import 'package:robin_ai/presentation/config/services/app_settings_service.dart';
import 'package:robin_ai/presentation/pages/context_list_page.dart';

// Model class for settings options
class SettingsOption {
  final String title;
  final IconData iconData;
  final Widget page;

  SettingsOption(
      {required this.title, required this.iconData, required this.page});
}

class SettingsPage extends StatelessWidget {
  final List<SettingsOption> options = [
    SettingsOption(
      title: 'API Keys',
      iconData: Icons.vpn_key,
      page: ServiceApiKeysPage(),
    ),
    SettingsOption(
      title: 'Context Config',
      iconData: FontAwesomeIcons.brain,
      page: ContextListPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView.builder(
        itemCount: options.length,
        itemBuilder: (BuildContext context, int index) {
          final option = options[index];
          return ListTile(
            leading: Icon(option.iconData),
            title: Text(option.title),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => option.page),
              );
            },
          );
        },
      ),
    );
  }
}

class ServiceApiKeysPage extends StatefulWidget {
  @override
  _ServiceApiKeysPageState createState() => _ServiceApiKeysPageState();
}

class _ServiceApiKeysPageState extends State<ServiceApiKeysPage> {
  TextEditingController _openAIController = TextEditingController();
  TextEditingController _groqController = TextEditingController();
  TextEditingController _dyrektywaController = TextEditingController();
  AppSettingsService _appSettingsService = AppSettingsService();

  @override
  void initState() {
    super.initState();
    _loadApiKeys();
  }

  void _loadApiKeys() async {
    // Assuming readApiKeys returns a Map<String, String> with the keys
    var keys = await _appSettingsService.readApiKeys();
    setState(() {
      _openAIController.text =
          obscureApiKey(keys[ServiceName.openai.name] as String);
      _groqController.text =
          obscureApiKey(keys[ServiceName.groq.name] as String);
      _dyrektywaController.text =
          obscureApiKey(keys[ServiceName.dyrektywa.name] as String);
    });
  }

  String obscureApiKey(String key) {
    if (key == null || key.isEmpty) {
      return '';
    } else if (key.length <= 7) {
      return key.replaceAll(RegExp('.'), '*');
    } else {
      return '${key.substring(0, 3)}...${key.substring(key.length - 4)}';
    }
  }

  void _updateOpenAIKey(String value) {
    _appSettingsService.updateApiKey(ServiceName.openai.name, value);
  }

  void _updateGroqKey(String value) {
    _appSettingsService.updateApiKey(ServiceName.groq.name, value);
  }

  void _updateDyrektywaKey(String value) {
    _appSettingsService.updateApiKey(ServiceName.dyrektywa.name, value);
  }

  @override
  void dispose() {
    _openAIController.dispose();
    _groqController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Keys'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('OpenAI'),
            subtitle: TextFormField(
              controller: _openAIController,
              decoration: InputDecoration(
                hintText: 'Enter OpenAI API Key',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                filled: true,
                fillColor: Colors.teal.shade50,
              ),
              onChanged: _updateOpenAIKey,
              // Remove the next two lines to display the text normally but obscured
              // obscureText: true,
              // obscuringCharacter: '*',
            ),
          ),
          ListTile(
            title: Text('Groq'),
            subtitle: TextFormField(
              controller: _groqController,
              decoration: InputDecoration(
                hintText: 'Enter Groq API Key',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                filled: true,
                fillColor: Colors.teal.shade50,
              ),
              onChanged: _updateGroqKey,
              // Remove the next two lines to display the text normally but obscured
              // obscureText: true,
              // obscuringCharacter: '*',
            ),
          ),
          ListTile(
            title: Text('Dyrektywa'),
            subtitle: TextFormField(
              controller: _dyrektywaController,
              decoration: InputDecoration(
                hintText: 'Enter Dyrektywa API Key',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                filled: true,
                fillColor: Colors.teal.shade50,
              ),
              onChanged: _updateDyrektywaKey,
              // Remove the next two lines to display the text normally but obscured
              // obscureText: true,
              // obscuringCharacter: '*',
            ),
          ),
        ],
      ),
    );
  }
}
