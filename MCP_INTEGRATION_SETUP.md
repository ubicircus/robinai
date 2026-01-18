# MCP Server Integration Setup

## Overview

The MCP (Model Context Protocol) server integration has been implemented. This allows the app to connect to remote MCP servers, discover their tools, and use them in conversations with the LLM.

## Setup Steps

### 1. Generate Hive Adapter

Before running the app, you need to generate the Hive adapter for `McpServerConfig`:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate `lib/data/model/mcp_server_config.g.dart`.

### 2. Register Hive Adapter

After generating the adapter, uncomment the registration line in `lib/main.dart`:

```dart
Hive.registerAdapter(McpServerConfigAdapter());
```

### 3. Usage

1. Open the app and go to Settings
2. Tap on "MCP Servers"
3. Add a new MCP server with:
   - Server name
   - Server URL (e.g., `https://example.com/mcp`)
   - Transport type (HTTP)
   - Authentication (if required)
4. Test the connection
5. Enable the server to make its tools available to the LLM

## Features

- Add, edit, and delete MCP servers
- Test server connections
- Enable/disable servers
- Automatic tool discovery from enabled servers
- Tool execution with automatic result formatting
- Error handling and user-friendly messages

## Architecture

- **MCP Client**: Handles communication with MCP servers via HTTP
- **MCP Server Service**: Manages server configurations and persistence
- **Tool Executor**: Parses and executes tool calls from LLM responses
- **Tool Result Formatter**: Formats raw tool results using LLM agent with GenUI components
- **System Prompt Builder**: Integrates MCP tools into LLM system prompts

## Tool Execution Flow

1. LLM decides to call a tool and includes it in the response
2. Tool executor parses the tool call
3. Tool is executed via MCP client
4. Raw result is sent to formatting agent (LLM)
5. Formatting agent formats result using GenUI components
6. Formatted result is displayed in chat
