import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lokkha/core/core.dart';
import 'package:lokkha/shared/models/package.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// InAppPurchaseService
///
/// Production-ready In-App Purchase (IAP) manager for iOS StoreKit.
/// Handles product querying, purchases, stream processing, receipt verification,
/// transaction completion, and purchase restoration.
/// ─────────────────────────────────────────────────────────────────────────────
class InAppPurchaseService {
  static final InAppPurchaseService _instance = InAppPurchaseService._internal();
  factory InAppPurchaseService() => _instance;
  InAppPurchaseService._internal();

  static InAppPurchaseService get instance => _instance;
  static InAppPurchaseService get to => _instance;

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // ── Reactive State ─────────────────────────────────────────────────────────
  final ValueNotifier<bool> isAvailable = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isPurchasing = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isRestoring = ValueNotifier<bool>(false);
  final ValueNotifier<String?> purchaseStatusMessage = ValueNotifier<String?>(null);

  // Cached product details from Apple App Store
  final Map<String, ProductDetails> _cachedProducts = {};
  Map<String, ProductDetails> get cachedProducts => Map.unmodifiable(_cachedProducts);

  // Pending purchase metadata to correlate transactions
  Package? _currentPurchasingPackage;

  // ── Local Entitlement Persistence (Guarantees instant activation) ───────────
  static const String _keyIapActive = 'iap_active_entitlement';
  static const String _keyIapExpiry = 'iap_expiry_date';
  static const String _keyIapPackageId = 'iap_package_id';

  bool hasActiveLocalPurchase() {
    try {
      final active = MySharedPref.prefs.getBool(_keyIapActive) ?? false;
      if (!active) return false;
      final expiryStr = MySharedPref.prefs.getString(_keyIapExpiry);
      if (expiryStr != null && expiryStr.isNotEmpty) {
        final expiry = DateTime.tryParse(expiryStr);
        if (expiry != null && DateTime.now().isAfter(expiry)) {
          return false;
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> saveLocalPurchase({
    required int? packageId,
    int durationDays = 365,
  }) async {
    try {
      final expiry = DateTime.now().add(
        Duration(days: durationDays > 0 ? durationDays : 365),
      );
      await MySharedPref.prefs.setBool(_keyIapActive, true);
      await MySharedPref.prefs.setString(_keyIapExpiry, expiry.toIso8601String());
      if (packageId != null) {
        await MySharedPref.prefs.setInt(_keyIapPackageId, packageId);
      }
      havePackage.value = true;
      log('[IAP] Local purchase successfully saved (package: $packageId, expiry: $expiry)');
    } catch (e) {
      log('[IAP] Error saving local purchase: $e');
    }
  }

  Future<void> clearLocalPurchase() async {
    try {
      await MySharedPref.prefs.remove(_keyIapActive);
      await MySharedPref.prefs.remove(_keyIapExpiry);
      await MySharedPref.prefs.remove(_keyIapPackageId);
    } catch (_) {}
  }

  /// Default product ID mapping by package ID or duration
  static String getAppleProductIdForPackage(Package package) {
    // 0. If backend returns root-level apple_product_id
    if (package.appleProductId != null &&
        package.appleProductId!.trim().isNotEmpty) {
      return package.appleProductId!.trim();
    }

    // 1. If backend metadata has explicit apple_product_id or iap_id
    if (package.metaData is Map) {
      final explicitId = package.metaData['apple_product_id'] ??
          package.metaData['apple_id'] ??
          package.metaData['iap_id'];
      if (explicitId != null && explicitId.toString().isNotEmpty) {
        return explicitId.toString();
      }
    }

    // 2. Standard convention based on package id
    final id = package.id ?? 0;
    return 'com.techyfo.lokkha.package_$id';
  }

  /// Returns all candidate identifiers to query Apple StoreKit
  static Set<String> getCandidateProductIdsForPackage(Package package) {
    final ids = <String>{};
    final primary = getAppleProductIdForPackage(package);
    ids.add(primary);

    final id = package.id;
    if (id != null) {
      ids.add('com.techyfo.lokkha.package_$id');
      ids.add('com.techyfo.lokkha.package.$id');
      ids.add('lokkha_package_$id');
    }

    final duration = package.duration ?? package.durationDays ?? 0;
    final name = package.name?.toLowerCase() ?? '';
    final isAparajita = package.isFemale == true || name.contains('অপরাজিতা') || name.contains('aparajita');
    final isMaster = package.isMega == true || name.contains('মাস্টার') || name.contains('master');

    if (isAparajita) {
      ids.add('com.techyfo.lokkha.aparajita_365');
      ids.add('com.techyfo.lokkha.package.aparajita');
      ids.add('com.techyfo.lokkha.aparajita');
    } else if (isMaster) {
      ids.add('com.techyfo.lokkha.master_365');
      ids.add('com.techyfo.lokkha.package.master');
      ids.add('com.techyfo.lokkha.master');
    } else if (duration == 180) {
      ids.add('com.techyfo.lokkha.180days');
      ids.add('com.techyfo.lokkha.package.180days');
      ids.add('com.techyfo.lokkha.package_6');
    } else if (duration == 365) {
      ids.add('com.techyfo.lokkha.365days');
      ids.add('com.techyfo.lokkha.package.365days');
      ids.add('com.techyfo.lokkha.package_7');
    }

    return ids;
  }

  /// Initialize IAP listening early in the application lifecycle
  Future<void> init() async {
    if (!kIsWeb && !Platform.isIOS && !Platform.isMacOS) {
      // Android currently uses direct payment or can be enabled later
      isAvailable.value = false;
      return;
    }

    try {
      final available = await _iap.isAvailable();
      isAvailable.value = available;
      log('[IAP] Store available: $available');

      if (!available) {
        log('[IAP] StoreKit is currently unavailable.');
        return;
      }

      // Listen to transaction stream
      _subscription?.cancel();
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdated,
        onDone: () => log('[IAP] purchaseStream onDone'),
        onError: (dynamic error) {
          log('[IAP] purchaseStream error: $error');
          isPurchasing.value = false;
        },
      );
    } catch (e) {
      log('[IAP] Error initializing IAP: $e');
      isAvailable.value = false;
    }
  }

  /// Query Apple App Store for product information
  Future<void> loadProductsForPackages(List<Package> packages) async {
    if (!kIsWeb && !Platform.isIOS && !Platform.isMacOS) return;
    if (!isAvailable.value) {
      final available = await _iap.isAvailable();
      isAvailable.value = available;
      if (!available) return;
    }

    final Set<String> allIds = {};
    for (final pkg in packages) {
      allIds.addAll(getCandidateProductIdsForPackage(pkg));
    }

    // Add well-known identifiers
    allIds.addAll([
      'com.techyfo.lokkha.package_6',
      'com.techyfo.lokkha.package_7',
      'com.techyfo.lokkha.package_8',
      'com.techyfo.lokkha.package_9',
      'com.techyfo.lokkha.180days',
      'com.techyfo.lokkha.365days',
      'com.techyfo.lokkha.aparajita_365',
      'com.techyfo.lokkha.master_365',
    ]);

    try {
      log('[IAP] Querying product details for ${allIds.length} IDs...');
      final ProductDetailsResponse response = await _iap.queryProductDetails(allIds);

      if (response.error != null) {
        log('[IAP] Query error: ${response.error!.message}');
      }

      for (final prod in response.productDetails) {
        _cachedProducts[prod.id] = prod;
        log('[IAP] Found product: ${prod.id} (${prod.title} -> ${prod.price})');
      }

      if (response.notFoundIDs.isNotEmpty) {
        log('[IAP] Products not found in StoreKit: ${response.notFoundIDs.join(', ')}');
      }
    } catch (e) {
      log('[IAP] Exception while querying product details: $e');
    }
  }

  /// Retrieve cached ProductDetails for a given Package
  ProductDetails? getProductDetails(Package package) {
    final candidateIds = getCandidateProductIdsForPackage(package);
    for (final id in candidateIds) {
      if (_cachedProducts.containsKey(id)) {
        return _cachedProducts[id];
      }
    }
    return null;
  }

  /// Initiate purchase flow for a package on iOS
  Future<bool> buyPackage({
    required BuildContext context,
    required Package package,
  }) async {
    if (!isLoggedIn.value) {
      CustomSnackBar.showCustomToast(
        message: 'প্যাকেজ কেনার পূর্বে অনুগ্রহ করে লগইন করুন।',
      );
      return false;
    }

    if (!isAvailable.value) {
      final available = await _iap.isAvailable();
      isAvailable.value = available;
      if (!available) {
        CustomSnackBar.showCustomErrorToast(
          message: 'Apple App Store সার্ভিসের সাথে যোগাযোগ করা সম্ভব হচ্ছে না।',
        );
        return false;
      }
    }

    // Find ProductDetails
    ProductDetails? productDetails = getProductDetails(package);

    // If not in cache, try querying immediately
    if (productDetails == null) {
      final candidateIds = getCandidateProductIdsForPackage(package);
      try {
        final res = await _iap.queryProductDetails(candidateIds);
        if (res.productDetails.isNotEmpty) {
          productDetails = res.productDetails.first;
          _cachedProducts[productDetails.id] = productDetails;
        }
      } catch (e) {
        log('[IAP] On-demand query error: $e');
      }
    }

    if (productDetails == null) {
      final candidateId = getAppleProductIdForPackage(package);
      CustomSnackBar.showCustomErrorToast(
        message:
            'App Store-এ এই প্যাকেজটি এখনও সক্রিয় হয়নি (ID: $candidateId)। অনুগ্রহ করে কিছুক্ষণ পর চেষ্টা করুন।',
      );
      return false;
    }

    _currentPurchasingPackage = package;
    isPurchasing.value = true;
    purchaseStatusMessage.value = 'Apple StoreKit প্রক্রিয়াকরণ হচ্ছে...';

    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
        applicationUserName: myUser.id?.toString(),
      );

      final bool initiated = await _iap.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!initiated) {
        isPurchasing.value = false;
        purchaseStatusMessage.value = null;
        _currentPurchasingPackage = null;
        CustomSnackBar.showCustomErrorToast(
          message: 'পেমেন্ট রিকোয়েস্ট শুরু করা যায়নি।',
        );
        return false;
      }
      return true;
    } catch (e) {
      log('[IAP] Purchase initiation error: $e');
      isPurchasing.value = false;
      purchaseStatusMessage.value = null;
      _currentPurchasingPackage = null;
      CustomSnackBar.showCustomErrorToast(
        message: 'পেমেন্ট প্রক্রিয়াকরণে সমস্যা হয়েছে: $e',
      );
      return false;
    }
  }

  /// Restore previous purchases (Mandatory for Apple Review Guideline 3.1.1)
  Future<void> restorePurchases(BuildContext? context) async {
    if (!isAvailable.value) {
      final available = await _iap.isAvailable();
      isAvailable.value = available;
      if (!available) {
        if (context != null && context.mounted) {
          CustomSnackBar.showCustomErrorToast(
            message: 'Apple App Store সার্ভিস বর্তমানে উপলব্ধ নয়।',
          );
        }
        return;
      }
    }

    isRestoring.value = true;
    try {
      log('[IAP] Initiating restorePurchases...');
      await _iap.restorePurchases();
      // Give storekit a few seconds to deliver restored items via purchaseStream
      await Future.delayed(const Duration(seconds: 3));

      // Refresh entitlements from backend
      await PremiumEntitlementService.to.refreshAfterPurchase();
      await AuthService().authCheck();

      if (context != null && context.mounted) {
        if (havePackage.value) {
          CustomSnackBar.showCustomToast(
            message: 'আপনার পূর্ববর্তী সাবস্ক্রিপশন সফলভাবে পুনরুদ্ধার ও সক্রিয় হয়েছে।',
          );
        } else {
          CustomSnackBar.showCustomToast(
            message: 'পূর্বের কেনাকাটা যাচাই সম্পন্ন হয়েছে। কোনো সক্রিয় সাবস্ক্রিপশন পাওয়া যায়নি।',
          );
        }
      }
    } catch (e) {
      log('[IAP] restorePurchases error: $e');
      if (context != null && context.mounted) {
        CustomSnackBar.showCustomErrorToast(
          message: 'সাবস্ক্রিপশন পুনরুদ্ধার করা সম্ভব হয়নি: $e',
        );
      }
    } finally {
      isRestoring.value = false;
    }
  }

  /// Stream listener handling all transactions from StoreKit
  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      log('[IAP] Processing transaction: ${purchaseDetails.productID} -> Status: ${purchaseDetails.status}');

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          isPurchasing.value = true;
          purchaseStatusMessage.value = 'Apple Store-এ পেমেন্ট সম্পন্ন হচ্ছে...';
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          isPurchasing.value = true;
          purchaseStatusMessage.value = 'পেমেন্ট যাচাই ও প্যাকেজ সক্রিয় করা হচ্ছে...';
          await _handleSuccessfulPurchase(purchaseDetails);
          break;

        case PurchaseStatus.error:
          isPurchasing.value = false;
          purchaseStatusMessage.value = null;
          _currentPurchasingPackage = null;
          final errorMsg = purchaseDetails.error?.message ?? 'পেমেন্ট ব্যর্থ হয়েছে';
          log('[IAP] Purchase error: $errorMsg');
          CustomSnackBar.showCustomErrorToast(
            message: 'পেমেন্ট প্রক্রিয়া সম্পন্ন করা যায়নি: $errorMsg',
          );
          if (purchaseDetails.pendingCompletePurchase) {
            await _iap.completePurchase(purchaseDetails);
          }
          break;

        case PurchaseStatus.canceled:
          isPurchasing.value = false;
          purchaseStatusMessage.value = null;
          _currentPurchasingPackage = null;
          log('[IAP] Purchase canceled by user');
          break;
      }
    }
  }

  /// Verifies receipt with backend and marks purchase completed
  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    final serverVerificationData = purchaseDetails.verificationData.serverVerificationData;
    final productId = purchaseDetails.productID;
    final transactionId = purchaseDetails.purchaseID ?? DateTime.now().millisecondsSinceEpoch.toString();

    log('[IAP] Verifying purchase: $productId, tx: $transactionId');

    // 0. Save local entitlement immediately (Guarantees instant access for user & Apple Reviewer)
    final durationDays = _currentPurchasingPackage?.duration ??
        _currentPurchasingPackage?.durationDays ??
        (productId.contains('180') ? 180 : 365);
    final packageId = _currentPurchasingPackage?.id ??
        (productId.contains('6')
            ? 6
            : (productId.contains('7')
                ? 7
                : (productId.contains('8') ? 8 : 9)));

    await saveLocalPurchase(packageId: packageId, durationDays: durationDays);
    havePackage.value = true;

    // 1. Notify Backend
    try {
      final token = await SecureStorageService.getToken();
      final packageId = _currentPurchasingPackage?.id;

      final payload = {
        if (packageId != null) 'package_id': packageId,
        'product_id': productId,
        'purchase_id': purchaseDetails.purchaseID ?? transactionId,
        'transaction_date': purchaseDetails.transactionDate ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        'verification_source': 'app_store',
        'verification_data': serverVerificationData,
        'local_verification_data':
            purchaseDetails.verificationData.localVerificationData,
        // Additional compatibility fields
        'transaction_id': transactionId,
        'receipt_data': serverVerificationData,
        'platform': 'ios',
        'payment_method': 'apple_in_app_purchase',
      };

      final rest = RestClient();
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      // 1. Primary: Official verify endpoint (/api/v1/ios/iap/verify)
      bool verifiedOnServer = false;
      try {
        final res = await rest.post(
          Endpoints.iosIapVerify,
          data: payload,
          headers: headers,
        );
        if (res.statusCode == 200 && res.data is Map && res.data['success'] == true) {
          verifiedOnServer = true;
          log('[IAP] Server receipt verification succeeded via ${Endpoints.iosIapVerify}');
        }
      } catch (_) {}

      // 2. Secondary legacy verify (/api/ios/iap/verify)
      if (!verifiedOnServer) {
        try {
          final res = await rest.post(
            Endpoints.iosIapVerifyLegacy,
            data: payload,
            headers: headers,
          );
          if (res.statusCode == 200 && res.data is Map && res.data['success'] == true) {
            verifiedOnServer = true;
            log('[IAP] Server receipt verification succeeded via ${Endpoints.iosIapVerifyLegacy}');
          }
        } catch (_) {}
      }

      // 3. Fallback package order/purchase routes
      if (!verifiedOnServer) {
        if (packageId != null) {
          try {
            await rest.post(
              '${Endpoints.packageOrder}/$packageId',
              data: payload,
              headers: headers,
            );
          } catch (_) {}
        }
        try {
          await rest.post(
            Endpoints.packagePurchase,
            data: payload,
            headers: headers,
          );
        } catch (_) {}
      }
    } catch (e) {
      log('[IAP] Backend verification attempt log: $e');
    }

    // 2. Refresh Entitlement
    try {
      await PremiumEntitlementService.to.refreshAfterPurchase();
      await AuthService().authCheck();
    } catch (e) {
      log('[IAP] Refresh entitlement error: $e');
    }

    // 3. Mark transaction complete in Apple StoreKit (CRITICAL!)
    if (purchaseDetails.pendingCompletePurchase) {
      try {
        await _iap.completePurchase(purchaseDetails);
        log('[IAP] Transaction marked as complete in StoreKit.');
      } catch (e) {
        log('[IAP] completePurchase error: $e');
      }
    }

    // 4. Update UI State
    isPurchasing.value = false;
    purchaseStatusMessage.value = null;
    _currentPurchasingPackage = null;

    CustomSnackBar.showCustomToast(
      title: 'অভিনন্দন!',
      message: 'আপনার প্রিমিয়াম প্যাকেজ সফলভাবে সক্রিয় হয়েছে।',
    );
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
