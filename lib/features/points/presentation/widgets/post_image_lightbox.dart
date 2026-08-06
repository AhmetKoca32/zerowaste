import 'package:flutter/material.dart';

import '../../../../core/widgets/image_lightbox.dart';

/// Full-screen lightbox for a post photo (delegates to shared [showImageLightbox]).
Future<void> showPostImageLightbox(
  BuildContext context, {
  String? imageUrl,
  String? localPreviewPath,
}) {
  return showImageLightbox(
    context,
    imageUrl: imageUrl,
    localImagePath: localPreviewPath,
  );
}
