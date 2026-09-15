// import 'dart:convert';
// import 'dart:io';

// import 'package:http/http.dart' as http;
// import 'package:package_info_plus/package_info_plus.dart';

// class VersionChecker {
//   static Future<bool> isUpdateAvailable() async {
//     try {
//       final packageInfo = await PackageInfo.fromPlatform();
//        final currentVersion = packageInfo.version;

//       if (Platform.isAndroid) {
//         return _checkAndroidUpdate(currentVersion, packageInfo.packageName);
//       } else if (Platform.isIOS) {
//         return _checkIOSUpdate(currentVersion, packageInfo.packageName);
//       }
//       return false;
//     } catch (e) {
//       return false; // Fail silently
//     }
//   }

//   static Future<bool> _checkAndroidUpdate(
//       String currentVersion, String packageName) async {
//     final url = Uri.parse(
//         'https://play.google.com/store/apps/details?id=$packageName&hl=en');
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final RegExp versionRegExp = RegExp(r'\[\[\[\"\d+\.\d+\.\d+');
//       final matches = versionRegExp.firstMatch(response.body);

//       if (matches != null) {
//         final storeVersion = matches.group(0)?.replaceAll('[[[', '') ?? '';
//         return _shouldUpdate(currentVersion, storeVersion);
//       }
//     }
//     return false;
//   }

//   static Future<bool> _checkIOSUpdate(
//       String currentVersion, String bundleId) async {
//     final url = Uri.parse('https://itunes.apple.com/lookup?bundleId=$bundleId');
//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final jsonData = json.decode(response.body);
//       if (jsonData['resultCount'] > 0) {
//         final storeVersion = jsonData['results'][0]['version'];
//         return _shouldUpdate(currentVersion, storeVersion.toString());
//       }
//     }
//     return false;
//   }

//   static bool _shouldUpdate(String currentVersion, String storeVersion) {
//     final currentParts = currentVersion.split('.').map(int.parse).toList();
//     final storeParts = storeVersion.split('.').map(int.parse).toList();

//     // Compare version segments
//     for (int i = 0; i < storeParts.length; i++) {
//       if (i >= currentParts.length) return true;
//       if (storeParts[i] > currentParts[i]) return true;
//       if (storeParts[i] < currentParts[i]) return false;
//     }
//     return false;
//   }
// }
//
