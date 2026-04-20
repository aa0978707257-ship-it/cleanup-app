import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';
import '../../services/subscription_manager.dart';
import '../../models/storage_info.dart';
import '../../utils/constants.dart';
import '../../utils/app_theme.dart';
import '../paywall/paywall_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  StorageInfo? _storage;

  @override
  void initState() {
    super.initState();
    StorageInfo.current().then((s) {
      if (mounted) setState(() => _storage = s);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionManager>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Subscription
          ListTile(
            leading: Icon(
              sub.isPro ? Icons.workspace_premium : Icons.workspace_premium_outlined,
              color: sub.isPro ? Colors.amber : Colors.grey,
            ),
            title: Text(sub.isPro ? 'Cleanup Pro' : 'Free Plan',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: sub.isPro
                ? null
                : ElevatedButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const PaywallView())),
                    child: const Text('Upgrade'),
                  ),
          ),
          const Divider(),

          // Storage
          if (_storage != null) ...[
            _settingsHeader('Storage'),
            _settingsRow('Total', _storage!.totalSpaceFormatted),
            _settingsRow('Used', _storage!.usedSpaceFormatted),
            _settingsRow('Available', _storage!.freeSpaceFormatted,
                valueColor: AppTheme.successColor),
            const Divider(),
          ],

          // General
          _settingsHeader('General'),
          ListTile(
            title: const Text('Restore Purchases'),
            onTap: () => sub.restorePurchases(),
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            onTap: () => launchUrl(Uri.parse(AppConstants.privacyPolicyUrl)),
          ),
          ListTile(
            title: const Text('Terms of Use'),
            onTap: () => launchUrl(Uri.parse(AppConstants.termsUrl)),
          ),
          ListTile(
            title: const Text('Rate Us'),
            onTap: () async {
              final review = InAppReview.instance;
              if (await review.isAvailable()) {
                review.requestReview();
              }
            },
          ),
          const Divider(),

          // About
          _settingsHeader('About'),
          _settingsRow('Version', '1.0.0'),
        ],
      ),
    );
  }

  Widget _settingsHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(title,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _settingsRow(String label, String value, {Color? valueColor}) {
    return ListTile(
      title: Text(label),
      trailing: Text(value,
          style: TextStyle(color: valueColor ?? Colors.grey[600])),
    );
  }
}
