import 'package:flutter/material.dart';
import 'package:atomx/atomx.dart';
import 'chat_controller.dart';
import 'contacts_controller.dart';
import 'models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ChatPage(title: 'Chat Demo'),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.title});

  final String title;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _chatController = ChatController();
  final _contactsController = ContactsController();
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chatController.loadMessages();
    _contactsController.loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: AtomxBuilder(
              builder: (context) {
                final messages = _chatController.messages;
                final messagesLength = messages.length;
                final messagesState = messages.state;

                if (messagesState == MessagesState.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView.builder(
                  itemCount: messagesLength,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ListTile(
                      title: Text(
                        _contactsController.getContactName(message.fromId),
                      ),
                      subtitle: Text(message.content),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      _chatController.sendMessage(
                        Message(
                          id: DateTime.now().toString(),
                          fromId: '1', // Current user
                          toId: '2', // Recipient
                          content: _messageController.text,
                          timestamp: DateTime.now(),
                        ),
                      );
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
