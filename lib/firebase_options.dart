import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBmW5IsEfSAgGEnZwLUc2Ay_IjBetjJSgU',
    authDomain: 'gohyang-market.firebaseapp.com',
    projectId: 'gohyang-market',
    storageBucket: 'gohyang-market.firebasestorage.app',
    messagingSenderId: '961204948552',
    appId: '1:961204948552:web:6582d9d9d9d9d9d9d9d9d9',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBmW5IsEfSAgGEnZwLUc2Ay_IjBetjJSgU',
    appId: '1:961204948552:android:82dc6e3386291370e0527d',
    messagingSenderId: '961204948552',
    projectId: 'gohyang-market',
    storageBucket: 'gohyang-market.firebasestorage.app',
  );
}
