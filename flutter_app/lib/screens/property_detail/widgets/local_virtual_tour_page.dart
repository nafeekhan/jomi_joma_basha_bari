import 'package:flutter/material.dart';

import '../../../config/app_theme.dart';
import '../../../models/scene.dart';
import 'hotspot_panorama_viewer.dart';

class LocalVirtualTourPage extends StatefulWidget {
  final String propertyTitle;
  final List<Scene> scenes;

  const LocalVirtualTourPage({super.key, required this.propertyTitle, required this.scenes});

  @override
  State<LocalVirtualTourPage> createState() => _LocalVirtualTourPageState();
}

class _LocalVirtualTourPageState extends State<LocalVirtualTourPage> {
  late Scene _currentScene;

  @override
  void initState() {
    super.initState();
    _currentScene = widget.scenes.first;
  }

  void _switchScene(String sceneId) {
    final target = widget.scenes.firstWhere((scene) => scene.id == sceneId, orElse: () => _currentScene);
    if (target.id == _currentScene.id) return;
    setState(() {
      _currentScene = target;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${widget.propertyTitle} • Virtual Tour'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: HotspotPanoramaViewer(
                scene: _currentScene,
                onHotspotTap: _switchScene,
              ),
            ),
          ),
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return DraggableScrollableSheet(
      initialChildSize: 0.15,
      minChildSize: 0.12,
      maxChildSize: 0.4,
      builder: (context, controller) {
        final rooms = widget.scenes;
        final viewpoints = widget.scenes; // For dummy data each room has a single viewpoint
        return Container(
          decoration: const BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Rooms', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: rooms.map((scene) => _buildThumbnail(scene, isRoom: true)).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Text('Viewpoints', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: viewpoints.map((scene) => _buildThumbnail(scene)).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThumbnail(Scene scene, {bool isRoom = false}) {
    final isActive = scene.id == _currentScene.id;
    final label = isRoom ? scene.sceneName : scene.name;
    final preview = scene.previewImageUrl ?? (scene.imagePaths.isNotEmpty ? scene.imagePaths.first : '');

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => _switchScene(scene.id),
        child: Container(
          width: 96,
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? AppTheme.primaryColor : Colors.white24,
              width: 2,
            ),
            boxShadow: [
              if (isActive)
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: preview.startsWith('http')
                    ? Image.network(preview, fit: BoxFit.cover)
                    : Image.asset(preview, fit: BoxFit.cover),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
