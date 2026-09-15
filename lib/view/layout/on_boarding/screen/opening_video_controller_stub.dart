import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

const String _hqOpeningAsset = 'assets/splash_video/opening_hq.mp4';

Future<VideoPlayerController> createOpeningVideoController(
  List<String> chunkPaths,
) async {
  try {
    // Prefer the real high-quality MP4 when it is bundled with the app.
    await rootBundle.load(_hqOpeningAsset);
    return VideoPlayerController.asset(
      _hqOpeningAsset,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
  } catch (_) {
    // Keep the legacy Base64 video as a safe fallback until the HQ asset is
    // available in the repository/build.
    final chunks = await Future.wait(chunkPaths.map(rootBundle.loadString));
    final encoded = chunks
        .map((chunk) => chunk.replaceAll(RegExp(r'\s+'), ''))
        .join();

    return VideoPlayerController.networkUrl(
      Uri.parse('data:video/mp4;base64,$encoded'),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );
  }
}
