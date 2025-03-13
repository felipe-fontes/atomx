# Atomx

<div align="center">

A value-centric state management library for Flutter, built on `ValueNotifier`. Atomx treats values and states as equals, allowing you to attach state directly to values instead of pages.

[![Flutter](https://img.shields.io/badge/Flutter-3.0.0-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0.0-blue.svg)](https://dart.dev)

</div>

## ✨ Features

<div align="center">

| 🎯 Value-Centric | 🔄 Reactive | 🎨 Composable | 🪶 Lightweight |
|----------------|-------------|--------------|---------------|
| State belongs to values | Automatic UI updates | Single builder | Native Flutter |

</div>

## 🚀 Why Atomx?

### 🎯 Value-Centric
State belongs to values, not pages. This means:
- Data owns its state (loading, error, success)
- UI simply reflects the data's state
- Components can be reused anywhere since they're not tied to page state
- State changes are automatically propagated to all listeners
- Testing is simpler as you can test state logic independently

For example, the same messages data can be displayed in different ways:
```dart
// Chat list Component
class ChatListComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AtomxBuilder(
      builder: (context) {
        final messages = GetIt.I<ChatController>().messages;
        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) => MessageTile(message: messages[index]),
        );
      },
    );
  }
}

// Chat grid Component
class ChatGridComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AtomxBuilder(
      builder: (context) {
        final messages = GetIt.I<ChatController>().messages;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemCount: messages.length,
          itemBuilder: (context, index) => MessageCard(message: messages[index]),
        );
      },
    );
  }
}
```

### 🔄 Reactive
UI automatically updates when values or states change. This means:
- No need for manual state propagation
- UI updates automatically when data changes
- No need for setState or other manual update triggers

For example, updating a user's profile automatically updates all UI components:
```dart
class ProfileController {
  final user = AtomxState<User, UserState>(User.empty(), UserState.initial);
  
  Future<void> updateProfile(String name) async {
    try {
      user.update(state: UserState.loading);
      final updatedUser = await api.updateProfile(name);
      user.update(value: updatedUser, state: UserState.loaded);
    } catch (e) {
      user.update(state: UserState.error);
    }
  }
}

// All these widgets will update automatically when user changes
class ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AtomxBuilder(
      builder: (context) {
        final user = GetIt.I<ProfileController>().user;
        return Text(user.value.name);
      },
    );
  }
}

class ProfileStats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AtomxBuilder(
      builder: (context) {
        final user = GetIt.I<ProfileController>().user;
        return Text('${user.value.posts} posts');
      },
    );
  }
}
```

### 🎨 Composable
Combine multiple value states in a single builder. This means:
- No need for multiple builders or listeners
- Clean and readable code
- Better performance as all states are handled in one place

For example, handling multiple states in a single builder:
```dart
class ProductDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AtomxBuilder(
      builder: (context) {
        final product = GetIt.I<ProductController>().product;
        final reviews = GetIt.I<ProductController>().reviews;
        final related = GetIt.I<ProductController>().related;
        
        // Handle all loading states in one place
        if (product.state == ProductState.loading ||
            reviews.state == ReviewsState.loading ||
            related.state == RelatedState.loading) {
          return LoadingIndicator();
        }
        
        // Handle all error states in one place
        if (product.state == ProductState.error ||
            reviews.state == ReviewsState.error ||
            related.state == RelatedState.error) {
          return ErrorView();
        }
        
        // Build UI with all data
        return Column(
          children: [
            ProductHeader(product: product.value),
            ReviewsList(reviews: reviews.value),
            RelatedProducts(products: related.value),
          ],
        );
      },
    );
  }
}
```

### 🪶 Lightweight
Built on Flutter's native `ValueNotifier`. This means:
- No external dependencies
- Small bundle size
- Familiar API for Flutter developers

For example, using native Flutter patterns:
```dart
// Familiar ValueNotifier pattern
final counter = Atomx<int>(0);

// Easy to understand state updates
counter.update(value: counter.value + 1);

// Simple state management
final user = AtomxState<User, UserState>(User.empty(), UserState.initial);
user.update(value: newUser, state: UserState.loaded);
```

## 📦 Observable Types

```dart
// 1. Basic value
final counter = Atomx<int>(0);

// 2. Value with state
final user = AtomxState<User, UserState>(User.empty(), UserState.initial);

// 3. List
final todos = AtomxList<Todo>([]);

// 4. Map
final users = AtomxMap<String, User>({});

// 5. List with state
final messages = AtomxListState<Message, MessagesState>([], MessagesState.initial);

// 6. Map with state
final contacts = AtomxMapState<String, Contact, ContactsState>({}, ContactsState.initial);
```

## 💬 Example: Chat App

```dart
// Create a controller to manage the chat domain
class ChatController {
  final currentUser = AtomxState<User, UserState>(User.empty(), UserState.initial);
  final messages = AtomxListState<Message, MessagesState>([], MessagesState.initial);
  final contacts = AtomxMapState<String, Contact, BaseState>({}, const LoadingState());

  Future<void> loadCurrentUser() async {
    currentUser.update(state: UserState.loading);
    try {
      final user = await fetchCurrentUser();
      currentUser.update(value: user, state: UserState.loaded);
    } catch (e) {
      currentUser.update(state: UserState.error);
    }
  }
}

// Create a reusable component that reacts to the controller
class MessageList extends StatelessWidget {
  final Function(Message) onMessageSelected;

  const MessageList({
    required this.onMessageSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = GetIt.I<ChatController>();

    return AtomxBuilder(
      builder: (context) {
        final user = controller.currentUser;
        final messages = controller.messages;
        final contacts = controller.contacts;
        
        if (user.state == UserState.loading || 
            messages.state == MessagesState.loading ||
            contacts.state is LoadingState) {
          return CircularProgressIndicator();
        }

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
              onTap: () => onMessageSelected(message),
            );
          },
        );
      },
    );
  }
}

// Use the component in any page
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: MessageList(
        onMessageSelected: (message) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MessageDetailsPage(messageId: message.id),
            ),
          );
        },
      ),
    );
  }
}
```

<div align="center">

See the example app for a complete implementation.

</div> 