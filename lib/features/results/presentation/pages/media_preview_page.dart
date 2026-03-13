import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_dedup_poc/core/utils/formatters.dart';
import 'package:media_dedup_poc/features/media_scan/domain/models/media_item.dart';

class MediaPreviewPage extends StatelessWidget {
  const MediaPreviewPage({
    super.key,
    required this.item,
    this.scoreLabel,
  });

  final MediaItem item;
  final String? scoreLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.fileName),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: item.width == 0 || item.height == 0
                  ? 1
                  : item.width / item.height,
              child: Image.file(
                File(item.path),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Colors.black12,
                  child: Center(
                    child: Icon(Icons.broken_image_outlined, size: 48),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text('${item.width} x ${item.height}')),
              Chip(label: Text(Formatters.bytes(item.sizeBytes))),
              if (scoreLabel != null) Chip(label: Text(scoreLabel!)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Location',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          SelectableText(item.path),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: item.path));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('File path copied')),
                );
              }
            },
            child: const Text('Copy File Path'),
          ),
        ],
      ),
    );
  }
}
