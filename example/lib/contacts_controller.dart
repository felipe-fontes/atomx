import 'package:atomx/atomx.dart';
import 'models.dart';

enum ContactsState { initial, loading, loaded, error }

class ContactsController {
  final contacts = AtomxMapState<String, Contact, ContactsState>(
    {},
    ContactsState.initial,
  );

  final me = AtomxState<Contact, ContactsState>(
    const Contact(id: '1', name: 'Me'),
    ContactsState.initial,
  );

  Contact? getContact(String contactId) {
    return contacts.value[contactId];
  }

  Future<void> fetchMe() async {
    me.update(state: ContactsState.loading);
    // Simulate loading me
    await Future.delayed(const Duration(milliseconds: 500));
    me.update(
      value: const Contact(id: '1', name: 'Me'),
      state: ContactsState.loaded,
    );
  }

  Future<void> loadContacts() async {
    contacts.updateState(ContactsState.loading);
    // Simulate loading contacts
    await Future.delayed(const Duration(seconds: 1));
    contacts.updateMapAndState(
      value: {
        '2': const Contact(
          id: '2',
          name: 'Alice',
        ),
        '3': const Contact(
          id: '3',
          name: 'Bob',
        ),
      },
      state: ContactsState.loaded,
    );
  }

  String getContactName(String contactId) {
    return contacts.value[contactId]?.name ?? 'Unknown';
  }
} 