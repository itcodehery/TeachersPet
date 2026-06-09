# Google AdMob Production Setup Guide

Follow these steps to transition your app from test ads to a live Google AdMob account and start earning revenue.

## 1. Create an AdMob Account & Register Your App
1.  Go to [Google AdMob](https://admob.google.com/) and sign up or sign in.
2.  Navigate to **Apps** > **Add App**.
3.  Select the platform (**Android** or **iOS**).
4.  If your app is already on the Play Store/App Store, select "Yes" to link it. If not, select "No" (you can link it later).
5.  Repeat this for both Android and iOS if you are targeting both.

## 2. Update Global App IDs
Once your app is registered, you will receive an **App ID** (formatted as `ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy`). You must update this in your platform-specific configuration files.

### **Android**
Update `teachers_app/android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="YOUR_ANDROID_APP_ID"/>
```

### **iOS**
Update `teachers_app/ios/Runner/Info.plist`:
```xml
<key>GADApplicationIdentifier</key>
<string>YOUR_IOS_APP_ID</string>
```

## 3. Create Ad Units & Update `AdHelper`
In the AdMob dashboard, go to **Ad units** for your app and click **Add ad unit**.
1.  Create a **Banner** ad unit and an **Interstitial** ad unit.
2.  Copy the **Ad Unit IDs** (formatted as `ca-app-pub-xxxxxxxxxxxxxxxx/zzzzzzzzzz`).
3.  Update these in `teachers_app/lib/core/services/ad_helper.dart`:

```dart
static String get bannerAdUnitId {
  if (Platform.isAndroid) {
    return 'YOUR_REAL_ANDROID_BANNER_UNIT_ID';
  } else if (Platform.isIOS) {
    return 'YOUR_REAL_IOS_BANNER_UNIT_ID';
  }
  // ...
}

static String get interstitialAdUnitId {
  if (Platform.isAndroid) {
    return 'YOUR_REAL_ANDROID_INTERSTITIAL_UNIT_ID';
  } else if (Platform.isIOS) {
    return 'YOUR_REAL_IOS_INTERSTITIAL_UNIT_ID';
  }
  // ...
}
```

## 4. Revenue & Verification Requirements
Google will not serve live ads or pay out revenue until these steps are completed:
*   **Payment Information**: Complete your address and tax information in the **Payments** section of AdMob.
*   **Identity Verification**: Google may require you to verify your identity via a PIN sent to your physical address.
*   **App-ads.txt**: Once you have a website for your app, host an `app-ads.txt` file on your domain. This is essential for ad authorization.
*   **App Review**: New apps usually enter a "Getting Ready" status. Google will review your app once it's linked to a store listing before showing full-volume ads.

## 5. Safety: Testing with Live IDs
**Warning:** Never click on your own live ads. This will result in an account suspension for "Invalid Click Activity."

To safely test on your own device while using production IDs, find your **Test Device ID** in the console logs when running the app and add it to `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Optional: Add your device ID to test safely with production IDs
  /*
  MobileAds.instance.updateRequestConfiguration(
    RequestConfiguration(testDeviceIds: ['YOUR_DEVICE_ID']),
  );
  */
  
  MobileAds.instance.initialize();
  // ... rest of your main function
}
```

## 6. App Store Requirements (iOS Only)
For iOS, you should also consider:
*   **App Tracking Transparency (ATT)**: If you are targeting iOS 14.5+, you must ask users for permission to track them for ads. You will need to add the `NSUserTrackingUsageDescription` key to your `Info.plist` and use the `app_tracking_transparency` package.
*   **SKAdNetwork**: Ensure your `Info.plist` includes the [SKAdNetwork identifiers](https://developers.google.com/admob/ios/quick-start#update_your_infoplist) for AdMob and its partners.
