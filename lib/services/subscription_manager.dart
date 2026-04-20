import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

class SubscriptionManager extends ChangeNotifier {
  static const _revenueCatApiKeyAndroid = 'YOUR_REVENUECAT_ANDROID_API_KEY';
  static const _revenueCatApiKeyIos = 'YOUR_REVENUECAT_IOS_API_KEY';
  static const _proEntitlement = 'pro';

  bool _isPro = false;
  List<StoreProduct> _products = [];
  bool _isLoading = false;
  bool _showPaywall = false;

  bool get isPro => _isPro;
  List<StoreProduct> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  bool get showPaywall => _showPaywall;

  set showPaywall(bool value) {
    _showPaywall = value;
    notifyListeners();
  }

  // -----------------------------------------------------------------------
  // Initialisation
  // -----------------------------------------------------------------------

  /// Configure RevenueCat and check the current entitlement status.
  Future<void> init({required bool isIos}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final apiKey =
          isIos ? _revenueCatApiKeyIos : _revenueCatApiKeyAndroid;

      final configuration = PurchasesConfiguration(apiKey);
      await Purchases.configure(configuration);

      // Listen for customer info changes.
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);

      // Check initial status.
      final customerInfo = await Purchases.getCustomerInfo();
      _updateProStatus(customerInfo);

      await loadProducts();
    } catch (e) {
      debugPrint('SubscriptionManager.init error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // -----------------------------------------------------------------------
  // Products
  // -----------------------------------------------------------------------

  /// Fetch available products / packages from RevenueCat.
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current != null) {
        _products = current.availablePackages
            .map((p) => p.storeProduct)
            .toList();
      }
    } catch (e) {
      debugPrint('SubscriptionManager.loadProducts error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // -----------------------------------------------------------------------
  // Purchasing
  // -----------------------------------------------------------------------

  /// Purchase a specific package. Returns true on success.
  Future<bool> purchase(Package package) async {
    _isLoading = true;
    notifyListeners();

    try {
      final customerInfo = await Purchases.purchasePackage(package);
      _updateProStatus(customerInfo);

      _isLoading = false;
      notifyListeners();
      return _isPro;
    } on PurchasesErrorCode catch (e) {
      debugPrint('SubscriptionManager.purchase error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('SubscriptionManager.purchase error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Restore previous purchases. Returns true if the user now has Pro.
  Future<bool> restorePurchases() async {
    _isLoading = true;
    notifyListeners();

    try {
      final customerInfo = await Purchases.restorePurchases();
      _updateProStatus(customerInfo);

      _isLoading = false;
      notifyListeners();
      return _isPro;
    } catch (e) {
      debugPrint('SubscriptionManager.restorePurchases error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // -----------------------------------------------------------------------
  // Pro gate
  // -----------------------------------------------------------------------

  /// Check whether the user has Pro access. If not, sets [showPaywall] to
  /// true so the UI can present the paywall. Returns true if the user is Pro.
  bool requirePro() {
    if (_isPro) return true;
    _showPaywall = true;
    notifyListeners();
    return false;
  }

  /// Dismiss the paywall without purchasing.
  void dismissPaywall() {
    _showPaywall = false;
    notifyListeners();
  }

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------

  void _onCustomerInfoUpdated(CustomerInfo info) {
    _updateProStatus(info);
    notifyListeners();
  }

  void _updateProStatus(CustomerInfo info) {
    _isPro = info.entitlements.active.containsKey(_proEntitlement);
  }
}
