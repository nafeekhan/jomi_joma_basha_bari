import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:panorama/panorama.dart' as pano;

import '../../../models/scene.dart';

class HotspotPanoramaViewer extends StatelessWidget {
  final Scene scene;
  final ValueChanged<String>? onHotspotTap;

  const HotspotPanoramaViewer({super.key, required this.scene, this.onHotspotTap});

  @override
  Widget build(BuildContext context) {
    final imagePath = scene.previewImageUrl ?? scene.imagePaths.firstOrNull;

    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('No panorama available'),
        ),
      );
    }

    final initialLongitude = _radiansToDegrees(-scene.initialViewYaw);
    final initialLatitude = _radiansToDegrees(scene.initialViewPitch);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          pano.Panorama(
            animSpeed: 0.2,
            sensitivity: 2.0,
            minLatitude: -90,
            maxLatitude: 90,
            longitude: initialLongitude,
            latitude: initialLatitude,
            hotspots: (scene.hotspots ?? [])
                .where((hotspot) => hotspot.targetSceneId != null)
                .map((hotspot) {
              final longitude = _radiansToDegrees(-hotspot.yaw);
              final latitude = _radiansToDegrees(hotspot.pitch);
              return pano.Hotspot(
                latitude: latitude,
                longitude: longitude,
                width: 96,
                height: 40,
                widget: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.85),
                    foregroundColor: Colors.black87,
                    elevation: 3,
                  ),
                  onPressed: () {
                    final targetId = hotspot.targetSceneId;
                    if (targetId != null) {
                      onHotspotTap?.call(targetId);
                    }
                  },
                  icon: const Icon(Icons.arrow_circle_right_outlined),
                  label: Text(hotspot.title ?? hotspot.targetSceneName ?? 'Go'),
                ),
              );
            }).toList(),
            child: _buildPanoramaImage(imagePath),
          ),
          Positioned(
            left: 16,
            bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pan_tool_alt, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Drag to explore • Tap arrows to navigate',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Image _buildPanoramaImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(path, fit: BoxFit.cover);
    }
    return Image.asset(path, fit: BoxFit.cover);
  }

  double _radiansToDegrees(double radians) => radians * 180 / math.pi;
}

extension on List<String> {
  String? get firstOrNull => isNotEmpty ? first : null;
}
