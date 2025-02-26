# Atomx

A value-centric state management library for Flutter, built on `ValueNotifier`. Atomx treats values and states as equals, allowing you to attach state directly to values instead of pages.

## Why Atomx?

- 🎯 **Value-Centric**: State belongs to values, not pages
- 🔄 **Reactive**: UI automatically updates when values or states change
- 🎨 **Composable**: Combine multiple value states in a single builder
- 🪶 **Lightweight**: Built on Flutter's native `ValueNotifier`

## Observable Types

```dart
// 1. Basic value
final counter = Atomx<int>(0);

// 2. Value with state
final messages = AtomxState<List<Message>, LoadingState>([], LoadingState.initial);

// 3. List
final todos = AtomxList<Todo>([]);

// 4. Map
final users = AtomxMap<String, User>({});

// 5. List with state
final messages = AtomxListState<Message, MessagesState>([], MessagesState.initial);

// 6. Map with state
final contacts = AtomxMapState<String, Contact, ContactsState>({}, ContactsState.initial);
```

## Example: Chat App

```dart
// Define states (use enums for simple states)
enum MessagesState { initial, loading, loaded, error }
enum UserState { initial, loading, loaded, error }

// Or classes for complex states
abstract class BaseState {
  const BaseState();
}

class LoadingState extends BaseState {
  const LoadingState();
}

class ErrorState extends BaseState {
  final String message;
  const ErrorState(this.message);
}

class SuccessState<T> extends BaseState {
  final T data;
  const SuccessState(this.data);
}

// Define models with non-null properties
class User {
  final String id;
  final String name;
  final String avatarUrl;

  const User({
    required this.id,
    required this.name,
    required this.avatarUrl,
  });

  factory User.empty() => const User(
    id: '',
    name: 'Unknown',
    avatarUrl: '',
  );
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime timestamp;

  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });
}

// Create a controller
class ChatController {
  final currentUser = AtomxState<User, UserState>(User.empty(), UserState.initial);
  final messages = AtomxListState<Message, MessagesState>([], MessagesState.initial);
  final contacts = AtomxMapState<String, Contact, BaseState>({}, const LoadingState());

  Future<void> loadCurrentUser() async {
    currentUser.update(state: UserState.loading);
    try {
      final user = await fetchCurrentUser();
      currentUser.update(
        value: user,
        state: UserState.loaded,
      );
    } catch (e) {
      currentUser.update(state: UserState.error);
    }
  }

  Future<void> loadMessages(String chatId) async {
    messages.updateState(MessagesState.loading);
    try {
      final data = await fetchMessages(chatId);
      messages.updateAll(
        value: data,
        state: MessagesState.loaded,
      );
    } catch (e) {
      messages.updateState(MessagesState.error);
    }
  }

  Future<void> loadContacts() async {
    contacts.updateState(const LoadingState());
    try {
      final data = await fetchContacts();
      contacts.updateMapAndState(
        value: data,
        state: SuccessState(data),
      );
    } catch (e) {
      contacts.updateState(ErrorState(e.toString()));
    }
  }
}

// React to changes
AtomxBuilder(
  builder: (context) {
    final user = chatController.currentUser;
    final messages = chatController.messages;
    final contacts = chatController.contacts;
    
    // Show loading if any dependency is loading
    if (user.state == UserState.loading || 
        messages.state == MessagesState.loading ||
        contacts.state is LoadingState) {
      return CircularProgressIndicator();
    }

    // Show error if any dependency failed
    if (user.state == UserState.error ||
        messages.state == MessagesState.error ||
        contacts.state is ErrorState) {
      return Text('Something went wrong');
    }

    // Show chat when everything is loaded
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final contact = contacts[message.senderId];
        final isCurrentUser = message.senderId == user.value.id;
        
        return ListTile(
          leading: isCurrentUser ? null : CircleAvatar(
            backgroundImage: NetworkImage(contact?.avatarUrl ?? ''),
          ),
          title: Text(contact?.name ?? 'Unknown'),
          subtitle: Text(message.content),
          trailing: isCurrentUser ? Icon(Icons.check) : null,
        );
      },
    );
  },
);
```

See the example app for a complete implementation. 