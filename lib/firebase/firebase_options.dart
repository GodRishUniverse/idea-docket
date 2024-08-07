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
    apiKey: 'AIzaSyD85eDClN23UQPVGiFWtcVzNv6A6jl7QiY',
    appId: '1:100221988084:web:5d2a9de305ecbc93f142a1',
    messagingSenderId: '100221988084',
    projectId: 'idea-docket',
    authDomain: 'idea-docket.firebaseapp.com',
    storageBucket: 'idea-docket.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDIkk7TVwxILNb9J0Rtcz0XuIuD0UbnbP0',
    appId: '1:100221988084:ios:3464be983e6d8f06f142a1',
    messagingSenderId: '100221988084',
    projectId: 'idea-docket',
    storageBucket: 'idea-docket.appspot.com',
    iosBundleId: 'com.godrishuniverse.notesEveentsWebScraper',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDIkk7TVwxILNb9J0Rtcz0XuIuD0UbnbP0',
    appId: '1:100221988084:ios:3464be983e6d8f06f142a1',
    messagingSenderId: '100221988084',
    projectId: 'idea-docket',
    storageBucket: 'idea-docket.appspot.com',
    iosBundleId: 'com.godrishuniverse.notesEveentsWebScraper',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD85eDClN23UQPVGiFWtcVzNv6A6jl7QiY',
    appId: '1:100221988084:web:0e311e51d8ab4ecff142a1',
    messagingSenderId: '100221988084',
    projectId: 'idea-docket',
    authDomain: 'idea-docket.firebaseapp.com',
    storageBucket: 'idea-docket.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD2fbD_DrxlOz23kQJr091TPfOETXw82A4',
    appId: '1:100221988084:android:709938b15d41ee90f142a1',
    messagingSenderId: '100221988084',
    projectId: 'idea-docket',
    storageBucket: 'idea-docket.appspot.com',
  );

}