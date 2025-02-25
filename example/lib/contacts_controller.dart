import 'package:atomx/atomx.dart';
import 'models.dart';

enum ContactsState { initial, loading, loaded, error }

class ContactsController {
  final contacts = AtomxMapState<String, Contact, ContactsState>(
    {},
    ContactsState.initial,
  );

  void loadContacts() {
    contacts.updateState(ContactsState.loading);
    // Simulate loading contacts
    Future.delayed(const Duration(seconds: 1), () {
      contacts.updateMapAndState(
        value: {
          '1': Contact(id: '1', name: 'Alice'),
          '2': Contact(id: '2', name: 'Bob'),
        },
        state: ContactsState.loaded,
      );
    });
  }

  String getContactName(String contactId) {
    return contacts.value[contactId]?.name ?? 'Unknown';
  }
} 