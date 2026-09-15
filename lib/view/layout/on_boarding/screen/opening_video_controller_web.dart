import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

const String _hqOpeningAsset = 'assets/splash_video/opening_hq.mp4';

Future<VideoPlayerController> createOpeningVideoController(
  List<String> chunkPaths,
) async {
  try {
    // Prefer the bundled high-quality MP4 and expose it as a browser blob.
    final assetData = await rootBundle.load(_hqOpeningAsset);
    final bytes = assetData.buffer.asUint8List(
      assetData.offsetInBytes,
      assetData.lengthInBytes,
    );
    final blob = html.Blob(<Object>[bytes], 'video/mp4');
    final objectUrl = html.Url.createObjectUrlFromBlob(blob);

    return VideoPlayerController.networkUrl(
      Uri.parse(objectUrl),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
  } catch (_) {
    // Keep the legacy Base64 video as a safe fallback until the HQ asset is
    // available in the repository/build.
    final chunks = await Future.wait(chunkPaths.map(rootBundle.loadString));
    final encoded = chunks
        .map((chunk) => chunk.replaceAll(RegExp(r'\s+'), ''))
        .join();
    final bytes = base64Decode(encoded);
    final blob = html.Blob(<Object>[bytes], 'video/mp4');
    final objectUrl = html.Url.createObjectUrlFromBlob(blob);

    return VideoPlayerController.networkUrl(
      Uri.parse(objectUrl),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
  }
}
