import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

import 'local_storage.dart';

class AdManager {
  static Future<void> init() async {
    // Werbung wird nicht initialisiert
    debugPrint('Unity Ads Initialization skipped');
  }

  static Future<void> loadUnityIntAd() async {
    // Werbung wird nicht geladen
    debugPrint('Unity Interstitial Ad Load skipped');
  }

  static Future<void> loadUnityRewardedAd() async {
    // Werbung wird nicht geladen
    debugPrint('Unity Rewarded Ad Load skipped');
  }

  static Future<void> showIntAd() async {
    // Werbung wird nicht angezeigt
    debugPrint('Unity Interstitial Ad Show skipped');
  }

  static Future<void> showRewardedAd() async {
    // Werbung wird nicht angezeigt
    debugPrint('Unity Rewarded Ad Show skipped');
  }
}