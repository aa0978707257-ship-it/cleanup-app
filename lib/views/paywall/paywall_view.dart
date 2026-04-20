import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../services/subscription_manager.dart';
import '../../utils/app_theme.dart';

class PaywallView extends StatelessWidget {
  const PaywallView({super.key});

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionManager>();

    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Hero
            ShaderMask(
              shaderCallback: (bounds) => AppTheme.appGradient.createShader(bounds),
              child: const Icon(Icons.auto_awesome, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text('Cleanup Pro',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Unlock unlimited cleaning power',
                style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 32),

            // Features
            ..._features.map((f) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(f.$1, color: f.$3, size: 22),
                      const SizedBox(width: 12),
                      Expanded(child: Text(f.$2)),
                      const Icon(Icons.check_circle,
                          color: AppTheme.successColor, size: 18),
                    ],
                  ),
                )),
            const SizedBox(height: 32),

            // Plan cards
            _PlanCard(
              title: 'Weekly',
              price: '\$7.99/week',
              isSelected: true,
              isBestValue: false,
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _PlanCard(
              title: 'Yearly',
              price: '\$29.99/year',
              isSelected: false,
              isBestValue: true,
              onTap: () {},
            ),
            const SizedBox(height: 24),

            // CTA
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppTheme.appGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final offerings = await Purchases.getOfferings();
                    final package = offerings.current?.availablePackages.firstOrNull;
                    if (package != null) {
                      await sub.purchase(package);
                    }
                    if (context.mounted && sub.isPro) Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Start Free Trial',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Fine print
            Text('7-day free trial, then auto-renews',
                style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () => sub.restorePurchases(),
                    child: const Text('Restore', style: TextStyle(fontSize: 12))),
                TextButton(
                    onPressed: () {},
                    child: const Text('Privacy', style: TextStyle(fontSize: 12))),
                TextButton(
                    onPressed: () {},
                    child: const Text('Terms', style: TextStyle(fontSize: 12))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static const _features = [
    (Icons.copy, 'Unlimited duplicate cleaning', AppTheme.dangerColor),
    (Icons.photo_library, 'Smart similar photo detection', AppTheme.warningColor),
    (Icons.compress, 'Photo & video compression', AppTheme.secondaryColor),
    (Icons.people, 'Contact merge & cleanup', AppTheme.primaryColor),
    (Icons.lock, 'Secret Space vault', AppTheme.successColor),
    (Icons.screenshot, 'Screenshot bulk delete', Colors.teal),
  ];
}

class _PlanCard extends StatelessWidget {
  final String title, price;
  final bool isSelected, isBestValue;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title, required this.price,
    required this.isSelected, required this.isBestValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.05) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (isBestValue) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('BEST VALUE',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Text(price,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
