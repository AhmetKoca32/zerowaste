import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Full-screen lightbox for a network or local image.
/// Tap outside / close / back to dismiss. Pinch-zoom via [InteractiveViewer].
Future<void> showImageLightbox(
  BuildContext context, {
  String? imageUrl,
  String? localImagePath,
}) async {
  final hasRemote = imageUrl != null &&
      (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));
  final hasLocal = localImagePath != null &&
      localImagePath.isNotEmpty &&
      File(localImagePath).existsSync();
  if (!hasRemote && !hasLocal) return;

  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.92),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, animation, secondaryAnimation) {
      return SafeArea(
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(ctx).pop(),
                child: const SizedBox.expand(),
              ),
              Center(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: GestureDetector(
                    onTap: () {},
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(ctx).width,
                        maxHeight: MediaQuery.sizeOf(ctx).height * 0.85,
                      ),
                      child: hasRemote
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.contain,
                              placeholder: (_, _) => const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white54,
                                ),
                              ),
                              errorWidget: (_, _, _) => const Icon(
                                Icons.broken_image_outlined,
                                color: Colors.white70,
                                size: 48,
                              ),
                            )
                          : Image.file(
                              File(localImagePath!),
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.broken_image_outlined,
                                color: Colors.white70,
                                size: 48,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ],
          ),
        ),
      );
    },
    transitionBuilder: (ctx, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}
