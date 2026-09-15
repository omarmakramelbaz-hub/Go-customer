// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:package_info_plus/package_info_plus.dart';
// import 'package:url_launcher/url_launcher.dart';

// void showUpdateDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     barrierDismissible: false, // User must take action
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text("New Version Available"),
//         content: const Text(
//             "Please update to the latest version for new features and improvements."),
//         actions: <Widget>[
//           TextButton(
//             child: const Text("Later"),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           TextButton(
//             child: const Text("Update Now"),
//             onPressed: () => _launchStore(context),
//           ),
//         ],
//       );
//     },
//   );
// }

// void _launchStore(BuildContext context) async {
//   final packageInfo = await PackageInfo.fromPlatform();
//   final String url = Platform.isAndroid
//       ? "market://details?id=${packageInfo.packageName}"
//       : "https://apps.apple.com/us/app/fasakhaninja/id6741027064";

//   try {
//     if (await canLaunchUrl(Uri.parse(url))) {
//       await launchUrl(Uri.parse(url));
//     }
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Could not launch app store")),
//     );
//   }
//   Navigator.of(context).pop();
// }
