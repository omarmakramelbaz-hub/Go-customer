import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
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
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD9c9vLzy5vq0ZCpSJQn54bMPcNfaM-lbI',
    appId: '1:224648167390:android:d4d87f98dfe5ddf556274f',
    messagingSenderId: '224648167390',
    projectId: 'fasakhaninjatest',
    storageBucket: 'fasakhaninjatest.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDes7Ooxg_gu-CzcE5VH4m02pZF4uN9zLQ',
    appId: '1:224648167390:ios:7b0a8844f171b56556274f',
    messagingSenderId: '224648167390',
    projectId: 'fasakhaninjatest',
    storageBucket: 'fasakhaninjatest.firebasestorage.app',
    iosClientId: '224648167390-mn9e3ukrrdukvudoepad5o3vlv3pej46.apps.googleusercontent.com',
    iosBundleId: 'com.faskhaninja.clients',
  );
}
