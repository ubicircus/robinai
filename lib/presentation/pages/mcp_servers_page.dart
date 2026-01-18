import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:robin_ai/data/model/mcp_server_config.dart';
import 'package:robin_ai/presentation/config/services/mcp_server_service.dart';
import 'package:uuid/uuid.dart';

class McpServersPage extends StatefulWidget {
  @override
  _McpServersPageState createState() => _McpServersPageState();
}

class _McpServersPageState extends State<McpServersPage> {
  final McpServerService _mcpService = McpServerService();
  List<McpServerConfig> _servers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServers();
  }

  Future<void> _loadServers() async {
    setState(() => _isLoading = true);
    try {
      final servers = await _mcpService.getAllServers();
      setState(() {
        _servers = servers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load servers: $e')),
        );
      }
    }
  }

  Future<void> _addServer() async {
    final result = await Navigator.push<McpServerConfig>(
      context,
      MaterialPageRoute(
        builder: (context) => AddMcpServerPage(),
        fullscreenDialog: true,
      ),
    );

    if (result != null) {
      await _mcpService.saveServerConfig(result);
      _loadServers();
    }
  }

  Future<void> _editServer(McpServerConfig server) async {
    final result = await Navigator.push<McpServerConfig>(
      context,
      MaterialPageRoute(
        builder: (context) => AddMcpServerPage(server: server),
        fullscreenDialog: true,
      ),
    );

    if (result != null) {
      await _mcpService.saveServerConfig(result);
      _loadServers();
    }
  }

  Future<void> _deleteServer(McpServerConfig server) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Delete Server'),
        content: Text('Are you sure you want to delete "${server.name}"? This action cannot be undone.'),
        actions: [
          CupertinoDialogAction(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: Text('Delete'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _mcpService.deleteServer(server.id);
      _loadServers();
    }
  }

  Future<void> _testConnection(McpServerConfig server) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('Testing connection to ${server.name}...'),
        duration: Duration(seconds: 2),
      ),
    );

    final success = await _mcpService.testConnection(server);
    
    await _loadServers(); // Refresh to update lastTested and lastError

    if (mounted) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Connection successful!'
              : 'Connection failed: ${server.lastError ?? "Unknown error"}'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleEnabled(McpServerConfig server) async {
    final updated = McpServerConfig(
      id: server.id,
      name: server.name,
      url: server.url,
      transportType: server.transportType,
      authType: server.authType,
      authToken: server.authToken,
      isEnabled: !server.isEnabled,
      lastTested: server.lastTested,
      lastError: server.lastError,
    );
    await _mcpService.saveServerConfig(updated);
    _loadServers();
  }

  Color _getStatusColor(McpServerConfig server) {
    if (!server.isEnabled) return Colors.grey;
    if (server.lastError != null) return Colors.red;
    if (server.lastTested != null) return Colors.green;
    return Colors.orange;
  }

  IconData _getStatusIcon(McpServerConfig server) {
    if (!server.isEnabled) return Icons.block;
    if (server.lastError != null) return Icons.error;
    if (server.lastTested != null) return Icons.check_circle;
    return Icons.help_outline;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MCP Servers'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _servers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No MCP servers configured',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add a server to get started',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _servers.length,
                  itemBuilder: (context, index) {
                    final server = _servers[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(server).withOpacity(0.2),
                          child: Icon(
                            _getStatusIcon(server),
                            color: _getStatusColor(server),
                          ),
                        ),
                        title: Text(server.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(server.url),
                            if (server.lastTested != null)
                              Text(
                                'Last tested: ${_formatDate(server.lastTested!)}',
                                style: TextStyle(fontSize: 12),
                              ),
                            if (server.lastError != null)
                              Text(
                                'Error: ${server.lastError}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: server.isEnabled,
                              onChanged: (_) => _toggleEnabled(server),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'test':
                                    _testConnection(server);
                                    break;
                                  case 'edit':
                                    _editServer(server);
                                    break;
                                  case 'delete':
                                    _deleteServer(server);
                                    break;
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'test',
                                  child: Row(
                                    children: [
                                      Icon(Icons.network_check),
                                      SizedBox(width: 8),
                                      Text('Test Connection'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      SizedBox(width: 8),
                                      Text('Edit'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addServer,
        child: Icon(Icons.add),
        tooltip: 'Add MCP Server',
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

class AddMcpServerPage extends StatefulWidget {
  final McpServerConfig? server;

  AddMcpServerPage({this.server});

  @override
  _AddMcpServerPageState createState() => _AddMcpServerPageState();
}

class _AddMcpServerPageState extends State<AddMcpServerPage> {
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _authTokenController = TextEditingController();
  TransportType _transportType = TransportType.http;
  AuthType _authType = AuthType.none;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    if (widget.server != null) {
      _nameController.text = widget.server!.name;
      _urlController.text = widget.server!.url;
      _transportType = widget.server!.transportType;
      _authType = widget.server!.authType;
      _authTokenController.text = widget.server!.authToken ?? '';
    }
  }

  bool get _isFormValid {
    return _nameController.text.isNotEmpty &&
        _urlController.text.isNotEmpty &&
        Uri.tryParse(_urlController.text) != null &&
        (_authType != AuthType.bearerToken || _authTokenController.text.isNotEmpty);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _authTokenController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    if (!_isFormValid) return;

    setState(() => _isTesting = true);

    try {
      final testConfig = McpServerConfig(
        id: widget.server?.id ?? Uuid().v4(),
        name: _nameController.text,
        url: _urlController.text,
        transportType: _transportType,
        authType: _authType,
        authToken: _authType == AuthType.bearerToken
            ? _authTokenController.text
            : null,
      );

      final mcpService = McpServerService();
      final success = await mcpService.testConnection(
        testConfig,
        persistResult: false,
      );

      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text(success ? 'Connection Successful' : 'Connection Failed'),
            content: Text(success
                ? 'The server is reachable and responding correctly.'
                : 'Unable to connect to the server. Please check the URL and credentials.'),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('Error'),
            content: Text('An error occurred: $e'),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTesting = false);
      }
    }
  }

  void _save() {
    if (!_isFormValid) return;

    final config = McpServerConfig(
      id: widget.server?.id ?? Uuid().v4(),
      name: _nameController.text,
      url: _urlController.text,
      transportType: _transportType,
      authType: _authType,
      authToken: _authType == AuthType.bearerToken
          ? _authTokenController.text
          : null,
      isEnabled: widget.server?.isEnabled ?? true,
    );

    Navigator.pop(context, config);
  }

  void _showTransportPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('Transport Type'),
        actions: TransportType.values.map((type) {
          return CupertinoActionSheetAction(
            child: Text(type == TransportType.http ? 'HTTP' : 'SSE'),
            onPressed: () {
              setState(() => _transportType = type);
              Navigator.pop(context);
            },
            isDefaultAction: _transportType == type,
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _showAuthPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text('Authentication'),
        actions: [
          CupertinoActionSheetAction(
            child: Text('None'),
            onPressed: () {
              setState(() => _authType = AuthType.none);
              Navigator.pop(context);
            },
            isDefaultAction: _authType == AuthType.none,
          ),
          CupertinoActionSheetAction(
            child: Text('Bearer Token'),
            onPressed: () {
              setState(() => _authType = AuthType.bearerToken);
              Navigator.pop(context);
            },
            isDefaultAction: _authType == AuthType.bearerToken,
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          widget.server == null ? 'New MCP Server' : 'Edit MCP Server',
          style: TextStyle(decoration: TextDecoration.none),
        ),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.pop(context),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _isFormValid ? _save : null,
          child: Text(
            'Save',
            style: TextStyle(
              color: _isFormValid
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.inactiveGray,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.none,
              decorationColor: Colors.transparent,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: ListView(
            children: [
              SizedBox(height: 16),
              // Server Information Section
              _buildSection(
                header: 'SERVER INFORMATION',
                children: [
                  _buildTextField(
                    controller: _nameController,
                    placeholder: 'Server Name',
                    onChanged: (_) => setState(() {}),
                  ),
                  _buildTextField(
                    controller: _urlController,
                    placeholder: 'Server URL',
                    keyboardType: TextInputType.url,
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
              
              SizedBox(height: 32),
              
              // Configuration Section
              _buildSection(
                header: 'CONFIGURATION',
                children: [
                  _buildPickerRow(
                    label: 'Transport Type',
                    value: _transportType == TransportType.http ? 'HTTP' : 'SSE',
                    onTap: _showTransportPicker,
                  ),
                  _buildPickerRow(
                    label: 'Authentication',
                    value: _authType == AuthType.none ? 'None' : 'Bearer Token',
                    onTap: _showAuthPicker,
                  ),
                ],
              ),
              
              if (_authType == AuthType.bearerToken) ...[
                SizedBox(height: 8),
                _buildSection(
                  header: '',
                  children: [
                    _buildTextField(
                      controller: _authTokenController,
                      placeholder: 'Auth Token',
                      obscureText: true,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ],
              
              SizedBox(height: 32),
              
              // Test Connection Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    color: (_isTesting || !_isFormValid)
                        ? CupertinoColors.quaternarySystemFill
                        : CupertinoColors.activeBlue,
                    disabledColor: CupertinoColors.quaternarySystemFill,
                    onPressed: _isTesting || !_isFormValid
                        ? null
                        : _testConnection,
                    child: _isTesting
                        ? CupertinoActivityIndicator(color: CupertinoColors.white)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.wifi, size: 20, color: CupertinoColors.white),
                              SizedBox(width: 8),
                              Text(
                                'Test Connection',
                                style: TextStyle(color: CupertinoColors.white),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              
              SizedBox(height: 32),
            ],
          ),
        ),
    );
  }

  Widget _buildSection({
    required String header,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              header,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: CupertinoColors.secondaryLabel,
                letterSpacing: -0.08,
                decoration: TextDecoration.none,
                decorationColor: Colors.transparent,
              ),
            ),
          ),
        ],
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: CupertinoColors.separator,
              width: 0.5,
            ),
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;
              return Column(
                children: [
                  child,
                  if (index < children.length - 1)
                    Divider(
                      height: 0.5,
                      indent: 16,
                      color: CupertinoColors.separator,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    TextInputType? keyboardType,
    bool obscureText = false,
    required ValueChanged<String> onChanged,
  }) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      keyboardType: keyboardType,
      obscureText: obscureText,
      autocorrect: false,
      enableSuggestions: false,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      style: TextStyle(
        fontSize: 17,
        color: CupertinoColors.label,
        decoration: TextDecoration.none,
        decorationColor: Colors.transparent,
      ),
      placeholderStyle: TextStyle(
        color: CupertinoColors.placeholderText,
        decoration: TextDecoration.none,
      ),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildPickerRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 17,
                  color: CupertinoColors.label,
                  decoration: TextDecoration.none,
                  decorationColor: Colors.transparent,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                color: CupertinoColors.secondaryLabel,
                decoration: TextDecoration.none,
                decorationColor: Colors.transparent,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              CupertinoIcons.right_chevron,
              size: 16,
              color: CupertinoColors.tertiaryLabel,
            ),
          ],
        ),
      ),
    );
  }
}
