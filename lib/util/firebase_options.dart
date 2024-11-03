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
   apiKey: 'AIzaSyAz_ZT1Uw_P8tincrWWjLdmxo8G6aQu8kA',
   appId: '1:492486980221:android:3a374543e52a88aa0e7714',
   messagingSenderId: '492486980221',
   projectId: 'desal-mcs',
   storageBucket: 'desal-mcs.appspot.com',
 );

 static const FirebaseOptions ios = FirebaseOptions(
   apiKey: 'AIzaSyAz_ZT1Uw_P8tincrWWjLdmxo8G6aQu8kA',
   appId: '1:492486980221:ios:42f2575a974681120e7714',
   messagingSenderId: '492486980221',
   projectId: 'desal-mcs',
   storageBucket: 'desal-mcs.appspot.com',
   iosClientId: '492486980221-egbbi5mefhm0qfhgvkiapbl9vqbf7ds2.apps.googleusercontent.com',
   iosBundleId: 'com.myminervahub.landmarkcoopMobileApp',
 );

}