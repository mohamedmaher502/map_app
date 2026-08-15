import 'package:flutter/material.dart';

/// (بند 06) ماركر بأيقونة محمّلة من URL مع fallback لو التحميل فشل
class UrlMarkerIcon extends StatelessWidget {
  final String url;
  final IconData fallbackIcon;
  final Color fallbackColor;
  final String? label;

  const UrlMarkerIcon({
    super.key,
    required this.url,
    required this.fallbackIcon,
    required this.fallbackColor,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4),
              ],
            ),
            child: Text(
              label!,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ),
        Expanded(
          child: Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              fallbackIcon,
              color: fallbackColor,
              size: 34,
            ),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            },
          ),
        ),
      ],
    );
  }
}
