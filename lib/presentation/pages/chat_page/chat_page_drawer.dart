import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:robin_ai/presentation/bloc/chat_bloc.dart';
import 'package:intl/intl.dart';

class DrawerChatPage extends StatelessWidget {
  final VoidCallback onSettingsUpdated;
  const DrawerChatPage({super.key, required this.onSettingsUpdated});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          BlocProvider.of<ChatBloc>(context).add(
              LoadThreadsEvent()); // Dispatch LoadThreadsEvent to fetch threads
          return Column(
            children: [
              Expanded(
                child: state.threads.isEmpty
                    ? const Center(
                        child: Text(
                            "No threads"), // Show "No threads" text instead of CircularProgressIndicator
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.threads.length,
                        itemBuilder: (context, index) {
                          final sortedThreads = state.threads
                            ..sort((a, b) => b.messages.first.timestamp
                                .compareTo(a.messages.first.timestamp));
                          final thread = sortedThreads[index];
                          final lastMessage = thread.messages.isNotEmpty
                              ? thread.messages.first
                              : null;
                          return GestureDetector(
                            onTap: () {
                              BlocProvider.of<ChatBloc>(context)
                                  .add(LoadMessagesEvent(threadId: thread.id));
                            },
                            child: ListTile(
                              title: Text(thread.name),
                              subtitle: lastMessage != null
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lastMessage
                                              .content, // Assuming `content` is the attribute for message content
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText2,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          "${DateFormat('HH:mm').format(lastMessage.timestamp)} ${DateFormat('dd MMM yy').format(lastMessage.timestamp)}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption,
                                        ),
                                      ],
                                    )
                                  : Text("No Messages"),
                            ),
                          );
                        },
                      ),
              ),
              Divider(),
              ListTile(
                title: Text("Settings"),
                leading: Icon(Icons.settings),
                onTap: () async {
                  await Navigator.pushNamed(context, '/settings');
                  onSettingsUpdated();
                },
              ),
              SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
