import 'package:flutter/material.dart';

class RazorImage extends StatelessWidget {
  final String? imageUrl;
  final String? thumbUrl;
  final double size;
  final BorderRadius borderRadius;

  const RazorImage({
    super.key,
    required this.imageUrl,
    required this.thumbUrl,
    this.size = 72,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    final String? best = (thumbUrl != null && thumbUrl!.isNotEmpty)
        ? thumbUrl
        : (imageUrl != null && imageUrl!.isNotEmpty)
            ? imageUrl
            : null;

    if (best == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme. surfaceContainerHighest,
          borderRadius: borderRadius,
        ),
        child: const Icon(Icons.image_not_supported_outlined),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        best,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          color: Theme.of(context).colorScheme. surfaceContainerHighest,
          child: const Icon(Icons.broken_image_outlined),
        ),
      ),
    );
  }
}
