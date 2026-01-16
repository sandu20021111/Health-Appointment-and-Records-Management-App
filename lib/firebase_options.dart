// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web not configured');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android; // Meka wenas kara
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  // MEKA ADD KARANNA (Details Firebase settings walin ganna)
  static const FirebaseOptions android = FirebaseOptions(
      apiKey: "AIzaSyCsjrdfnH0McMfd1_vjdy_f2vSfffSh98k",
      authDomain: "community-health-a88d7.firebaseapp.com",
      projectId: "community-health-a88d7",
      storageBucket: "community-health-a88d7.firebasestorage.app",
      messagingSenderId: "110374978382",
      appId: "1:110374978382:web:59ec8d50842a74af15141f"
  );
}