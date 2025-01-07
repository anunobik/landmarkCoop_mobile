import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
   show defaultTargetPlatform, TargetPlatform;

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
   
   // ignore: missing_enum_constant_in_switch
   switch (defaultTargetPlatform) {
     case TargetPlatform.android:
       return android;
     case TargetPlatform.iOS:
       return ios;
   }

   throw UnsupportedError(
     'DefaultFirebaseOptions are not supported for this platform.',
   );
 }

 static const FirebaseOptions android = FirebaseOptions(
   apiKey: 'AIzaSyB0oPtqqQZvkHqCZBHPl5QjZ5QjiXQ9gXs',
   appId: '1:704483577791:android:21c762de0052770f9f5b0a',
   messagingSenderId: '704483577791',
   projectId: 'royal-marshal',
   storageBucket: 'royal-marshal.appspot.com',
 );

 static const FirebaseOptions ios = FirebaseOptions(
   apiKey: 'AIzaSyBd0fxpnJYfgAskxHxCb64zYRsuhu8U2io',
   appId: '1:837768171714:ios:2ffb30d2bbfd1b17a4eb5b',
   messagingSenderId: '704483577791',
   projectId: 'royal-marshal',
   storageBucket: 'royal-marshal.appspot.com',
   iosClientId: '837768171714-gd0f5sa9vi8hrrthtgtocag2vlesabnm.apps.googleusercontent.com',
   iosBundleId: 'com.myminervahub.silvercoon',
 );

}