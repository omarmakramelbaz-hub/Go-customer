import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

import '../../../helpers/images/app_images.dart';
import '../../../helpers/routes/app_routers_import.dart';
import '../../../helpers/theme/app_colors.dart';
import '../zoom_image/zoom_image_screen.dart';
import 'custom_image.dart';

class CustomNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double radius;
  final BoxFit? fit;
  final bool hasZoom;

  const CustomNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.radius = 0,
    this.hasZoom = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasZoom
          ? () {
              NamedNavigatorImpl.push(
                ZoomImageScreen.routeName,
                arguments: ZoomImageArgs(path: imageUrl, type: ImageType.network),
              );
            }
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: fit,
          width: width,
          height: height,
          placeholder: (context, url) => CupertinoActivityIndicator(color: AppColors.mainAppColor),
          errorWidget: (context, url, error) {
            // Log the error for debugging
            debugPrint('Custom Network image Error: $error, URL: $url');

            // Handle specific HttpException with status code 404
            if (error is HttpException && error.message.contains('404')) {
              debugPrint('404 error: Image not found at URL: $url');
            }

            // Use a fallback image for all errors
            return Image.asset(
              AppImages.appLogo, // Provide a specific fallback asset for missing images
              fit: fit ?? BoxFit.fill,
              width: width,
              height: height,
            );
          },
        ),
      ),
    );
  }
}
