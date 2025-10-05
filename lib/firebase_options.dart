import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD7J-NO5suYbFCzUBaX5GBFk7mc7J30eVE',
    appId: '1:95358046515:web:10e4b3209c8c2c6b902e46',
    messagingSenderId: '95358046515',
    projectId: 'ceyiz-diz',
    authDomain: 'ceyiz-diz.firebaseapp.com',
    storageBucket: 'ceyiz-diz.firebasestorage.app',
    measurementId: 'G-PCWFGR1GWC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBaGgsR-55uTXyXcqJRxAUaO9r9zD5v42I',
    appId: '1:95358046515:android:c33a8249cb1e88f6902e46',
    messagingSenderId: '95358046515',
    projectId: 'ceyiz-diz',
    storageBucket: 'ceyiz-diz.firebasestorage.app',
  );
}