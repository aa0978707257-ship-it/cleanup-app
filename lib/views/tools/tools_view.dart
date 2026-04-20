import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

class ToolsView extends StatelessWidget {
  const ToolsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tools')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Cleanup Tools'),
          _toolCard(
            context,
            icon: Icons.email,
            title: 'Email Cleanup',
            subtitle: 'Clean promotional & spam emails',
            color: AppTheme.primaryColor,
            onTap: () {
              // TODO: Navigate to email cleanup
            },
          ),
          _toolCard(
            context,
            icon: Icons.calendar_month,
            title: 'Calendar Cleanup',
            subtitle: 'Remove past events & completed reminders',
            color: AppTheme.dangerColor,
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _sectionTitle('Fun'),
          _toolCard(
            context,
            icon: Icons.bolt,
            title: 'Charging Animation',
            subtitle: 'Customize your charging screen',
            color: Colors.amber,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(title,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _toolCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      required VoidCallback onTap}) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
