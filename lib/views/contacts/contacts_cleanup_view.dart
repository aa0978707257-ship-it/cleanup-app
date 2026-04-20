import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/contacts_service.dart';
import '../../utils/app_theme.dart';

class ContactsCleanupView extends StatelessWidget {
  const ContactsCleanupView({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ContactsCleanupService>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Contacts'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => service.scanContacts(),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Duplicates (${service.duplicateGroups.length})'),
              Tab(text: 'Incomplete (${service.incompleteContacts.length})'),
            ],
          ),
        ),
        body: service.isScanning
            ? const Center(child: CircularProgressIndicator())
            : service.duplicateGroups.isEmpty && service.incompleteContacts.isEmpty
                ? _buildEmptyState(service)
                : TabBarView(
                    children: [
                      _buildDuplicatesList(service),
                      _buildIncompleteList(service),
                    ],
                  ),
      ),
    );
  }

  Widget _buildEmptyState(ContactsCleanupService service) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 60, color: AppTheme.successColor),
          const SizedBox(height: 16),
          const Text('Contacts are clean!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => service.scanContacts(),
            child: const Text('Scan Contacts'),
          ),
        ],
      ),
    );
  }

  Widget _buildDuplicatesList(ContactsCleanupService service) {
    return ListView.builder(
      itemCount: service.duplicateGroups.length,
      itemBuilder: (ctx, i) {
        final group = service.duplicateGroups[i];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...group.contacts.map((c) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(c.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(c.phoneNumbers.isNotEmpty ? c.phoneNumbers.first : ''),
                    )),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => service.mergeContacts(group),
                    icon: const Icon(Icons.merge, size: 16),
                    label: const Text('Merge All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIncompleteList(ContactsCleanupService service) {
    return ListView.builder(
      itemCount: service.incompleteContacts.length,
      itemBuilder: (ctx, i) {
        final c = service.incompleteContacts[i];
        return ListTile(
          leading: const CircleAvatar(
              backgroundColor: AppTheme.warningColor,
              child: Icon(Icons.person, color: Colors.white)),
          title: Text(c.displayName),
          subtitle: Wrap(
            spacing: 4,
            children: [
              if (c.displayName.trim().isEmpty) _badge('No Name'),
              if (c.phoneNumbers.isEmpty) _badge('No Phone'),
              if (c.emails.isEmpty) _badge('No Email'),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: AppTheme.dangerColor),
            onPressed: () => service.deleteContact(c),
          ),
        );
      },
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text,
          style: const TextStyle(color: AppTheme.warningColor, fontSize: 10)),
    );
  }
}
