import 'dart:io';
import 'package:flutter/material.dart';
import '../../../models/scene.dart';

/// Model for a hotspot position
class HotspotModel {
  final String id;
  final double x; // Pixel position X
  final double y; // Pixel position Y
  final double yaw; // Yaw in radians
  final double pitch; // Pitch in radians
  final String targetSceneId;
  final String targetSceneName;
  final String title;

  HotspotModel({
    required this.id,
    required this.x,
    required this.y,
    required this.yaw,
    required this.pitch,
    required this.targetSceneId,
    required this.targetSceneName,
    required this.title,
  });

  Map<String, dynamic> toJson() => {
        'yaw': yaw,
        'pitch': pitch,
        'targetSceneId': targetSceneId,
        'targetSceneName': targetSceneName,
        'title': title,
      };
}

/// Interactive hotspot editor widget
class HotspotEditor extends StatefulWidget {
  final Scene scene;
  final List<Scene> allScenes;
  final Function(List<HotspotModel>) onHotspotsChanged;

  const HotspotEditor({
    Key? key,
    required this.scene,
    required this.allScenes,
    required this.onHotspotsChanged,
  }) : super(key: key);

  @override
  State<HotspotEditor> createState() => _HotspotEditorState();
}

class _HotspotEditorState extends State<HotspotEditor> {
  List<HotspotModel> hotspots = [];
  HotspotModel? selectedHotspot;
  Offset? clickPosition;
  bool showTargetSelector = false;

  @override
  Widget build(BuildContext context) {
    final availableScenes = widget.allScenes
        .where((s) => s.id != widget.scene.id)
        .toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.navigation, color: Color(0xFF667EEA), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎯 Add Navigation Hotspots',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Scene: ${widget.scene.name}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Info box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF667EEA).withOpacity(0.1),
                    const Color(0xFF764BA2).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(color: const Color(0xFF667EEA), width: 4),
                ),
              ),
              child: const Text(
                '💡 Tap on doors or passages in the image below to add navigation arrows. These hotspots will allow visitors to move between rooms.',
                style: TextStyle(
                  color: Color(0xFF4B5563),
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Interactive image preview
            if (widget.scene.imagePaths.isNotEmpty)
              _buildImagePreview(widget.scene.imagePaths.first, availableScenes)
            else
              _buildNoImagePlaceholder(),

            const SizedBox(height: 20),

            // Hotspots list
            _buildHotspotsList(),

            const SizedBox(height: 16),

            // Instructions
            _buildInstructions(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(String imagePath, List<Scene> availableScenes) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GestureDetector(
              onTapDown: (details) => _handleImageTap(details, availableScenes),
              child: Image.file(
                File(imagePath),
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Existing hotspot markers
          ...hotspots.map((hotspot) => _buildHotspotMarker(hotspot)),

          // Click preview marker
          if (clickPosition != null && showTargetSelector)
            _buildClickPreview(),

          // Instructions overlay
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '💡 Tap anywhere to add a navigation hotspot',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotspotMarker(HotspotModel hotspot) {
    final isSelected = selectedHotspot?.id == hotspot.id;

    return Positioned(
      left: hotspot.x - 25,
      top: hotspot.y - 25,
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedHotspot = hotspot;
          });
        },
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFF5576C).withOpacity(0.9)
                : const Color(0xFF667EEA).withOpacity(0.9),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 55,
                  left: -50,
                  child: Container(
                    width: 150,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      children: [
                        Text(
                          hotspot.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        ElevatedButton(
                          onPressed: () => _removeHotspot(hotspot.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: const Size(60, 24),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: const Text(
                            'Remove',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClickPreview() {
    return Positioned(
      left: clickPosition!.dx - 25,
      top: clickPosition!.dy - 25,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFFBBF18).withOpacity(0.9),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: const Center(
          child: Text(
            '?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoImagePlaceholder() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '📸 Upload a 360° image first',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotspotsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Navigation Hotspots (${hotspots.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        if (hotspots.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'No hotspots added yet. Tap on the image to add one!',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...hotspots.map((hotspot) => _buildHotspotListItem(hotspot)),
      ],
    );
  }

  Widget _buildHotspotListItem(HotspotModel hotspot) {
    final isSelected = selectedHotspot?.id == hotspot.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF667EEA).withOpacity(0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? const Color(0xFF667EEA) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotspot.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Yaw: ${(hotspot.yaw * 180 / 3.14159).toStringAsFixed(1)}°, Pitch: ${(hotspot.pitch * 180 / 3.14159).toStringAsFixed(1)}°',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _removeHotspot(hotspot.id),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: Colors.blue[600]!, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📖 How to Add Hotspots:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
          const SizedBox(height: 8),
          _buildInstructionStep('1', 'Tap on a door or passage in the image'),
          _buildInstructionStep('2', 'Select which room the door leads to'),
          _buildInstructionStep(
              '3', 'A navigation arrow will appear at that position'),
          _buildInstructionStep(
              '4', 'Repeat for all connections between rooms'),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF4B5563),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleImageTap(TapDownDetails details, List<Scene> availableScenes) {
    if (availableScenes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add more rooms to create navigation between them!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = details.localPosition;

    // Calculate yaw and pitch from click position
    // Assuming equirectangular projection:
    // yaw = (x / width) * 2π - π
    // pitch = (y / height) * π - π/2

    // For the positioned image, we need the image widget dimensions
    // Since the image is 300px height and full width
    final imageWidth = box.size.width;
    final imageHeight = 300.0;

    final x = localPosition.dx;
    final y = localPosition.dy - 100; // Adjust for padding/offset

    if (y < 0 || y > imageHeight) return; // Click outside image bounds

    final yaw = (x / imageWidth) * 2 * 3.14159 - 3.14159;
    final pitch = (y / imageHeight) * 3.14159 - 3.14159 / 2;

    setState(() {
      clickPosition = Offset(x, y + 100);
      showTargetSelector = true;
    });

    _showTargetSelectorDialog(availableScenes, x, y + 100, yaw, pitch);
  }

  void _showTargetSelectorDialog(
    List<Scene> availableScenes,
    double x,
    double y,
    double yaw,
    double pitch,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Target Room'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Position: Yaw ${(yaw * 180 / 3.14159).toStringAsFixed(1)}°, Pitch ${(pitch * 180 / 3.14159).toStringAsFixed(1)}°',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Where does this door/passage lead to?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...availableScenes.map(
              (scene) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ElevatedButton(
                  onPressed: () {
                    _addHotspot(scene, x, y, yaw, pitch);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667EEA),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('→ Go to ${scene.name}'),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                clickPosition = null;
                showTargetSelector = false;
              });
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _addHotspot(Scene targetScene, double x, double y, double yaw, double pitch) {
    final newHotspot = HotspotModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      x: x,
      y: y,
      yaw: yaw,
      pitch: pitch,
      targetSceneId: targetScene.id ?? '',
      targetSceneName: targetScene.name,
      title: 'Go to ${targetScene.name}',
    );

    setState(() {
      hotspots.add(newHotspot);
      clickPosition = null;
      showTargetSelector = false;
    });

    widget.onHotspotsChanged(hotspots);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Hotspot added to ${targetScene.name}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeHotspot(String id) {
    setState(() {
      hotspots.removeWhere((h) => h.id == id);
      if (selectedHotspot?.id == id) {
        selectedHotspot = null;
      }
    });

    widget.onHotspotsChanged(hotspots);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hotspot removed'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

