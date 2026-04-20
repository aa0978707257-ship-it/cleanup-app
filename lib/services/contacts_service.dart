import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

// ---------------------------------------------------------------------------
// Inline models
// ---------------------------------------------------------------------------

class ContactModel {
  final String id;
  final String displayName;
  final List<String> phoneNumbers;
  final List<String> emails;
  final bool hasPhoto;
  final bool isIncomplete;

  const ContactModel({
    required this.id,
    required this.displayName,
    required this.phoneNumbers,
    required this.emails,
    required this.hasPhoto,
    required this.isIncomplete,
  });

  factory ContactModel.fromContact(Contact contact) {
    final phones =
        contact.phones.map((p) => p.number).toList();
    final emails =
        contact.emails.map((e) => e.address).toList();
    final hasName = contact.displayName.trim().isNotEmpty;
    final hasPhone = phones.isNotEmpty;

    return ContactModel(
      id: contact.id,
      displayName: contact.displayName,
      phoneNumbers: phones,
      emails: emails,
      hasPhoto: contact.photo != null,
      isIncomplete: !hasName || !hasPhone,
    );
  }
}

class DuplicateContactGroup {
  final String matchKey;
  final List<ContactModel> contacts;

  const DuplicateContactGroup({
    required this.matchKey,
    required this.contacts,
  });
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

class ContactsCleanupService extends ChangeNotifier {
  bool _isScanning = false;
  List<DuplicateContactGroup> _duplicateGroups = [];
  List<ContactModel> _incompleteContacts = [];
  List<ContactModel> _allContacts = [];

  bool get isScanning => _isScanning;
  List<DuplicateContactGroup> get duplicateGroups => _duplicateGroups;
  List<ContactModel> get incompleteContacts => _incompleteContacts;
  List<ContactModel> get allContacts => _allContacts;

  // -----------------------------------------------------------------------
  // Scanning
  // -----------------------------------------------------------------------

  /// Fetch all device contacts, find duplicates and incomplete entries.
  Future<void> scanContacts() async {
    _isScanning = true;
    notifyListeners();

    try {
      final hasPermission = await FlutterContacts.requestPermission();
      if (!hasPermission) {
        _isScanning = false;
        notifyListeners();
        return;
      }

      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );

      _allContacts = contacts.map(ContactModel.fromContact).toList();

      // --- Find duplicates by normalized name ---
      final Map<String, List<ContactModel>> byName = {};
      for (final c in _allContacts) {
        final key = _normalizeName(c.displayName);
        if (key.isEmpty) continue;
        byName.putIfAbsent(key, () => []).add(c);
      }

      // --- Find duplicates by normalized phone number ---
      final Map<String, List<ContactModel>> byPhone = {};
      for (final c in _allContacts) {
        for (final phone in c.phoneNumbers) {
          final key = _normalizePhone(phone);
          if (key.isEmpty) continue;
          byPhone.putIfAbsent(key, () => []).add(c);
        }
      }

      // Merge both duplicate sources, dedup groups by contact ids.
      final Map<String, DuplicateContactGroup> groupMap = {};

      for (final entry in byName.entries) {
        if (entry.value.length > 1) {
          final groupKey = 'name:${entry.key}';
          groupMap[groupKey] = DuplicateContactGroup(
            matchKey: groupKey,
            contacts: entry.value,
          );
        }
      }

      for (final entry in byPhone.entries) {
        if (entry.value.length > 1) {
          final groupKey = 'phone:${entry.key}';
          if (!groupMap.containsKey(groupKey)) {
            groupMap[groupKey] = DuplicateContactGroup(
              matchKey: groupKey,
              contacts: entry.value,
            );
          }
        }
      }

      _duplicateGroups = groupMap.values.toList();
      _incompleteContacts =
          _allContacts.where((c) => c.isIncomplete).toList();

      _isScanning = false;
      notifyListeners();
    } catch (e) {
      debugPrint('ContactsCleanupService.scanContacts error: $e');
      _isScanning = false;
      notifyListeners();
    }
  }

  // -----------------------------------------------------------------------
  // Actions
  // -----------------------------------------------------------------------

  /// Merge a group of duplicate contacts into the first contact in the group.
  ///
  /// Copies phone numbers and emails from the others into the primary contact,
  /// then deletes the duplicates.
  Future<void> mergeContacts(DuplicateContactGroup group) async {
    if (group.contacts.length < 2) return;

    try {
      // Load the full Contact objects.
      final primary =
          await FlutterContacts.getContact(group.contacts.first.id);
      if (primary == null) return;

      final existingPhones =
          primary.phones.map((p) => _normalizePhone(p.number)).toSet();
      final existingEmails =
          primary.emails.map((e) => e.address.toLowerCase()).toSet();

      // Collect unique data from duplicates.
      for (var i = 1; i < group.contacts.length; i++) {
        final dup =
            await FlutterContacts.getContact(group.contacts[i].id);
        if (dup == null) continue;

        for (final phone in dup.phones) {
          if (!existingPhones.contains(_normalizePhone(phone.number))) {
            primary.phones.add(phone);
            existingPhones.add(_normalizePhone(phone.number));
          }
        }

        for (final email in dup.emails) {
          if (!existingEmails.contains(email.address.toLowerCase())) {
            primary.emails.add(email);
            existingEmails.add(email.address.toLowerCase());
          }
        }

        // Delete the duplicate.
        await FlutterContacts.deleteContact(dup);
      }

      // Update the primary contact with merged data.
      await FlutterContacts.updateContact(primary);

      // Re-scan to refresh the lists.
      await scanContacts();
    } catch (e) {
      debugPrint('ContactsCleanupService.mergeContacts error: $e');
    }
  }

  /// Delete a single contact from the device.
  Future<void> deleteContact(ContactModel contact) async {
    try {
      final full = await FlutterContacts.getContact(contact.id);
      if (full != null) {
        await FlutterContacts.deleteContact(full);
      }

      _allContacts.removeWhere((c) => c.id == contact.id);
      _incompleteContacts.removeWhere((c) => c.id == contact.id);
      for (final group in _duplicateGroups) {
        group.contacts.removeWhere((c) => c.id == contact.id);
      }
      _duplicateGroups.removeWhere((g) => g.contacts.length < 2);

      notifyListeners();
    } catch (e) {
      debugPrint('ContactsCleanupService.deleteContact error: $e');
    }
  }

  // -----------------------------------------------------------------------
  // Normalization helpers
  // -----------------------------------------------------------------------

  String _normalizeName(String name) {
    return name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }
}
