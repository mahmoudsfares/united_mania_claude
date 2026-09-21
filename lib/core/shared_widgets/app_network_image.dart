import 'package:flutter/material.dart';

import '../utils/app_images.dart';
import 'app_loader.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({super.key, required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = url;
    if (imageUrl == null || imageUrl.isEmpty) {
      return _placeholder();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (
        BuildContext context,
        Widget child,
        ImageChunkEvent? loadingProgress,
      ) {
        if (loadingProgress == null) {
          return child;
        }
        return const AppLoader();
      },
      errorBuilder: (
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) {
        return _placeholder();
      },
    );
  }

  Widget _placeholder() {
    return Image.asset(AppImages.articlePlaceholder, fit: BoxFit.cover);
  }
}
