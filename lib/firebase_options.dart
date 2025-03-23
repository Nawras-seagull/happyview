// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyDmjtwrDHi7OABoUXlJfGFxvHOQtc8dNSU',
    appId: '1:375472596129:web:a5ff17da762197bd7b3ce0',
    messagingSenderId: '375472596129',
    projectId: 'happy-view-ec151',
    authDomain: 'happy-view-ec151.firebaseapp.com',
    storageBucket: 'happy-view-ec151.firebasestorage.app',
    measurementId: 'G-ZZ2DK3N7VP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA0GvDc7SZOLAYUsRSY0eX4q5IcM2vWkEo',
    appId: '1:375472596129:android:b11fe22a619881907b3ce0',
    messagingSenderId: '375472596129',
    projectId: 'happy-view-ec151',
    storageBucket: 'happy-view-ec151.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBGe-TAxmL7fN_8SgMJbYRhMkMSuMHv5vk',
    appId: '1:375472596129:ios:ab861bac4c50c61a7b3ce0',
    messagingSenderId: '375472596129',
    projectId: 'happy-view-ec151',
    storageBucket: 'happy-view-ec151.firebasestorage.app',
    iosBundleId: 'com.example.happyview3',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBGe-TAxmL7fN_8SgMJbYRhMkMSuMHv5vk',
    appId: '1:375472596129:ios:ab861bac4c50c61a7b3ce0',
    messagingSenderId: '375472596129',
    projectId: 'happy-view-ec151',
    storageBucket: 'happy-view-ec151.firebasestorage.app',
    iosBundleId: 'com.example.happyview3',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDmjtwrDHi7OABoUXlJfGFxvHOQtc8dNSU',
    appId: '1:375472596129:web:0a4973e496347e1e7b3ce0',
    messagingSenderId: '375472596129',
    projectId: 'happy-view-ec151',
    authDomain: 'happy-view-ec151.firebaseapp.com',
    storageBucket: 'happy-view-ec151.firebasestorage.app',
    measurementId: 'G-P5N6Z9TX6J',
  );
}
