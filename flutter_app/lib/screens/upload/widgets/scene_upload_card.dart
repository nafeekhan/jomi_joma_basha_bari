import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/app_theme.dart';
import '../property_upload_screen.dart';

/// Scene Upload Card Widget
/// Displays a card for uploading 360° images for a single room/scene
class SceneUploadCard extends StatefulWidget {
  final SceneUploadData scene;
  final int index;
  final int totalScenes;
  final VoidCallback onRemove;
  final Function(SceneUploadData) onUpdate;

  const SceneUploadCard({
    super.key,
    required this.scene,
    required this.index,
    required this.totalScenes,
    required this.onRemove,
    required this.onUpdate,
  });

  @override
  State<SceneUploadCard> createState() => _SceneUploadCardState();
}

class _SceneUploadCardState extends State<SceneUploadCard> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.scene.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedImages = await _imagePicker.pickMultiImage();
    
    if (pickedImages.isNotEmpty) {
      final updatedScene = SceneUploadData(
        name: widget.scene.name,
        order: widget.scene.order,
        images: [
          ...widget.scene.images,
          ...pickedImages.map((xfile) => File(xfile.path)),
        ],
      );
      widget.onUpdate(updatedScene);
    }
  }

  void _removeImage(int imageIndex) {
    final images = List<File>.from(widget.scene.images);
    images.removeAt(imageIndex);
    
    final updatedScene = SceneUploadData(
      name: widget.scene.name,
      order: widget.scene.order,
      images: images,
    );
    widget.onUpdate(updatedScene);
  }

  void _updateName(String name) {
    final updatedScene = SceneUploadData(
      name: name,
      order: widget.scene.order,
      images: widget.scene.images,
    );
    widget.onUpdate(updatedScene);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Room/Scene Name',
                      hintText: 'e.g., Living Room, Bedroom, Kitchen',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: _updateName,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
                  onPressed: widget.onRemove,
                  tooltip: 'Remove scene',
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),

            // Help text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                border: Border.all(
                  color: AppTheme.warningColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: AppTheme.warningColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Upload 360° panoramic images (equirectangular format). You can upload multiple images for better quality.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),

            // Image grid
            if (widget.scene.images.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: widget.scene.images.length,
                itemBuilder: (context, index) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        child: Image.file(
                          widget.scene.images[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

            if (widget.scene.images.isNotEmpty)
              const SizedBox(height: AppTheme.spacingM),

            // Upload button
            OutlinedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: Text(
                widget.scene.images.isEmpty
                    ? 'Upload 360° Images'
                    : 'Add More Images',
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                foregroundColor: AppTheme.primaryColor,
              ),
            ),

            // Image count indicator
            if (widget.scene.images.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppTheme.successColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.scene.images.length} image(s) uploaded',
                      style: const TextStyle(
                        color: AppTheme.successColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
