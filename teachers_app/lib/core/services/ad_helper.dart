import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1667720226572708/6158072287';
    } else if (Platform.isIOS) {
      throw UnsupportedError('Unsupported platform');
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1667720226572708/6015077412';
    } else if (Platform.isIOS) {
      throw UnsupportedError('Unsupported platform');
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1667720226572708/4869516702';
    } else if (Platform.isIOS) {
      throw UnsupportedError('Unsupported platform');
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
