// Firebase configuration for YARAN
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey:
        'AIzaSyDN-PHD9GnYbwg1RjcSoc_LAsMPwNqnirs', // Get from google-services.json
    appId:
        '1:187515605080:android:8a91c3c2ffe6f5fa0d7a2d', // Already correct from screenshot
    messagingSenderId: '187515605080', // This is the project_number
    projectId: 'yaran-translator', // Get from google-services.json
    storageBucket:
        'yaran-translator.firebasestorage.app', // Get from google-services.json
  );
}
