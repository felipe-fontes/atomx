import 'package:atomx/atomx.dart';
import 'models.dart';

enum MessagesState { initial, loading, loaded, error }

class ChatController {
  final messages = AtomxListState<Message, MessagesState>(
    [],
    MessagesState.initial,
  );

  void sendMessage(Message message) {
    messages.add(message);
    // Simulate other person typing and responding
    _simulateResponse();
  }

  void _simulateResponse() {
    // Simulate typing delay between 1-2 seconds
    final delay = Duration(milliseconds: 1000 + (DateTime.now().millisecond % 1000));
    Future.delayed(delay, () {
      final responses = [
        'Hey! How are you?',
        'That\'s interesting!',
        'Tell me more about it',
        'I see what you mean',
        'Sounds good to me',
      ];
      
      final randomResponse = responses[DateTime.now().second % responses.length];
      
      messages.add(
        Message(
          id: DateTime.now().toString(),
          fromId: '2', // Bob's ID
          toId: '1', // Current user's ID
          content: randomResponse,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void loadMessages() {
    messages.updateState(MessagesState.loading);
    // Simulate loading messages
    Future.delayed(const Duration(seconds: 1), () {
      messages.updateAll(
        value: [],
        state: MessagesState.loaded,
      );
    });
  }
} 