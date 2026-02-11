# AdMob Setup Guide for Minty App

This guide explains how to configure Google AdMob for the Minty Flutter application.

## Prerequisites

1.  A Google AdMob account: [https://admob.google.com/](https://admob.google.com/)
2.  An App set up in AdMob (one for Android, one for iOS).

## Configuration Steps

### 1. Update App IDs

You must replace the Test App IDs with your actual AdMob App IDs before releasing the app.

**Android**
- Open `android/app/src/main/AndroidManifest.xml`.
- Find the `<meta-data>` tag with `android:name="com.google.android.gms.ads.APPLICATION_ID"`.
- Replace the `android:value` with your **Android App ID**.

**iOS**
- Open `ios/Runner/Info.plist`.
- Find the key `GADApplicationIdentifier`.
- Replace the string value with your **iOS App ID**.

### 2. Update Ad Unit IDs

The app uses a helper class to manage Ad Unit IDs.

- Open `lib/core/services/ad_helper.dart`.
- Replace the return values in the static getters with your actual Ad Unit IDs from the AdMob console.

| Ad Type | Helper Getter | Description |
| :--- | :--- | :--- |
| **Banner** | `AdHelper.bannerAdUnitId` | Displayed as a banner in various widgets. |
| **Interstitial** | `AdHelper.interstitialAdUnitId` | Fullscreen ad shown before PDF export/preview. |
| **Rewarded** | `AdHelper.rewardedAdUnitId` | (Optional) For future use. |

## How Ads are Implemented

### Banner Ads
Wrapper widget: `lib/core/widgets/banner_ad_widget.dart`
Usage:
```dart
const BannerAdWidget()
```
Place this widget anywhere you want to show a banner ad.

### Interstitial Ads (Fullscreen)
Service: `lib/core/services/fullscreen_ad_service.dart`

This service manages loading and showing interstitial ads. It automatically reloads an ad after one is dismissed.

**Usage:**
1.  **Initialize & Load**:
    Create an instance and call `loadAd()` (e.g., in `initState`).
    ```dart
    final _adService = FullscreenAdService();
    
    @override
    void initState() {
      super.initState();
      _adService.loadAd();
    }
    ```

2.  **Show Ad**:
    Call `showAdIfAvailable` with a callback function. The callback is executed after the ad is closed (or if the ad fails to show).
    ```dart
    _adService.showAdIfAvailable(() {
      // Perform action after ad is closed
      exportPdf();
    });
    ```

3.  **Dispose**:
    Don't forget to dispose of the service.
    ```dart
    @override
    void dispose() {
      _adService.dispose();
      super.dispose();
    }
    ```

## Testing

The app is currently configured with **Test IDs**.
- **Android Test App ID**: `ca-app-pub-3940256099942544~3347511713`
- **iOS Test App ID**: `ca-app-pub-3940256099942544~1458002511`

Ads should display with a "Test Ad" label.

> **Warning**: Never use real ads during development/testing, as this can lead to your AdMob account being suspended. Always use Test IDs or register your test device in the AdMob console.
