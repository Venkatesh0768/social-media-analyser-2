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
    apiKey: 'AIzaSyDiuD9P1r6dCadrjIujW8lolUcneJzPVt4',
    appId: '1:151600293989:web:89fd09a9cfa5e248bdbe8c',
    messagingSenderId: '151600293989',
    projectId: 'social-media-analyser-11938',
    authDomain: 'social-media-analyser-11938.firebaseapp.com',
    storageBucket: 'social-media-analyser-11938.firebasestorage.app',
    measurementId: 'G-CM885BWZZ7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCRnmsAZ6UnhPCePCL785uYPQUnTTbVBzs',
    appId: '1:151600293989:android:c8af1f1708d7dc18bdbe8c',
    messagingSenderId: '151600293989',
    projectId: 'social-media-analyser-11938',
    storageBucket: 'social-media-analyser-11938.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBG2RZzZsUgdy5ydl5j0EuoBW_4oe2NJ_Y',
    appId: '1:151600293989:ios:f79e4098fe9505a7bdbe8c',
    messagingSenderId: '151600293989',
    projectId: 'social-media-analyser-11938',
    storageBucket: 'social-media-analyser-11938.firebasestorage.app',
    iosBundleId: 'com.example.socialMedia',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBG2RZzZsUgdy5ydl5j0EuoBW_4oe2NJ_Y',
    appId: '1:151600293989:ios:f79e4098fe9505a7bdbe8c',
    messagingSenderId: '151600293989',
    projectId: 'social-media-analyser-11938',
    storageBucket: 'social-media-analyser-11938.firebasestorage.app',
    iosBundleId: 'com.example.socialMedia',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDiuD9P1r6dCadrjIujW8lolUcneJzPVt4',
    appId: '1:151600293989:web:23daa804bf0e765bbdbe8c',
    messagingSenderId: '151600293989',
    projectId: 'social-media-analyser-11938',
    authDomain: 'social-media-analyser-11938.firebaseapp.com',
    storageBucket: 'social-media-analyser-11938.firebasestorage.app',
    measurementId: 'G-K88QLQ7MDX',
  );
}
