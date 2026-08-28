import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedAvatar extends StatelessWidget {
  final String photoUrl;
  final String userId;
  final int photoUpdatedAt;
  final double radius;
  final String fallbackText;

  const CachedAvatar({
    super.key,
    required this.photoUrl,
    required this.userId,
    required this.photoUpdatedAt,
    required this.radius,
    required this.fallbackText,
  });

  @override
  Widget build(BuildContext context) {
    if (photoUrl.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Text(
          fallbackText.isNotEmpty ? fallbackText[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: radius * 0.65,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: photoUrl,
      cacheKey: '${userId}_$photoUpdatedAt',
      imageBuilder: (context, imageProvider) {
        return CircleAvatar(
          radius: radius,
          backgroundImage: imageProvider,
        );
      },
      placeholder: (context, url) {
        return CircleAvatar(
          radius: radius,
          backgroundColor:
              Theme.of(context).colorScheme.primaryContainer,
          child: SizedBox(
            width: radius * 0.45,
            height: radius * 0.45,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorWidget: (context, url, error) {
        return CircleAvatar(
          radius: radius,
          backgroundColor:
              Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            fallbackText.isNotEmpty
                ? fallbackText[0].toUpperCase()
                : '?',
            style: TextStyle(
              fontSize: radius * 0.65,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}