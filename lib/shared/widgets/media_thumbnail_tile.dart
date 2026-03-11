import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_dedup_poc/features/media_scan/domain/models/media_item.dart';

class MediaThumbnailTile extends StatelessWidget {
  const MediaThumbnailTile({
    super.key,
    required this.item,
    this.width = 84,
    this.height = 84,
    this.borderRadius = 16,
  });

  final MediaItem item;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final imagePath = item.thumbnailPath ?? item.path;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        color: Colors.black12,
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.black12,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image_outlined),
          ),
        ),
      ),
    );
  }
}
