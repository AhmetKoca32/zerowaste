import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Displays a post photo from Firebase Storage URL or a local preview path.
class PostImageThumbnail extends StatelessWidget {
  const PostImageThumbnail({
    super.key,
    this.imageUrl,
    this.localPreviewPath,
    this.fit = BoxFit.cover,
    this.placeholderColor,
    this.placeholderIcon,
    this.placeholderIconColor,
    this.placeholderIconOpacity = 0.4,
  });

  final String? imageUrl;
  final String? localPreviewPath;
  final BoxFit fit;
  final Color? placeholderColor;
  final IconData? placeholderIcon;
  final Color? placeholderIconColor;
  final double placeholderIconOpacity;

  bool get _hasRemote =>
      imageUrl != null &&
      (imageUrl!.startsWith('http://') || imageUrl!.startsWith('https://'));

  bool get _hasLocal =>
      localPreviewPath != null && File(localPreviewPath!).existsSync();

  @override
  Widget build(BuildContext context) {
    if (_hasRemote) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        placeholder: (_, _) => _placeholder(),
        errorWidget: (_, _, _) => _placeholder(),
      );
    }

    if (_hasLocal) {
      return Image.file(
        File(localPreviewPath!),
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: placeholderColor ?? AppColors.brandOrange.withOpacity(0.08),
      child: Center(
        child: Opacity(
          opacity: placeholderIconOpacity,
          child: Icon(
            placeholderIcon ?? Icons.image_outlined,
            size: 36,
            color: placeholderIconColor ?? AppColors.brandOrange,
          ),
        ),
      ),
    );
  }
}
