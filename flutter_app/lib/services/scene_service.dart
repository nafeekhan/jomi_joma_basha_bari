import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import '../models/scene.dart';
import '../config/api_config.dart';
import 'api_service.dart';

/// Scene Service (for 360 tours)
class SceneService {
  final ApiService _apiService;

  SceneService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  /// Get all scenes for a property
  Future<List<Scene>> getPropertyScenes(String propertyId) async {
    try {
      final response = await _apiService.get(ApiConfig.propertyScenes(propertyId));

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final scenesList = data['scenes'] as List;
        return scenesList
            .map((s) => Scene.fromJson(s as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(response['message'] as String? ?? 'Failed to fetch scenes');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Get scenes error: $e');
    }
  }

  /// Get scene by ID (lazy loaded with images and hotspots)
  Future<Scene> getSceneById(String sceneId) async {
    try {
      final response = await _apiService.get(ApiConfig.sceneById(sceneId));

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return Scene.fromJson(data['scene'] as Map<String, dynamic>);
      } else {
        throw ApiException(response['message'] as String? ?? 'Failed to fetch scene');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Get scene error: $e');
    }
  }

  /// Create new scene for a property
  Future<Scene> createScene({
    required String propertyId,
    required String sceneName,
    required int sceneOrder,
    double initialViewYaw = 0,
    double initialViewPitch = 0,
    double initialViewFov = 1.5708,
    List<File>? images,
  }) async {
    try {
      final fields = {
        'scene_name': sceneName,
        'scene_order': sceneOrder.toString(),
        'initial_view_yaw': initialViewYaw.toString(),
        'initial_view_pitch': initialViewPitch.toString(),
        'initial_view_fov': initialViewFov.toString(),
      };

      final files = <http.MultipartFile>[];
      if (images != null) {
        for (final image in images) {
          final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
          final file = await http.MultipartFile.fromPath(
            'scene_images',
            image.path,
            contentType: http.MediaType.parse(mimeType),
          );
          files.add(file);
        }
      }

      final response = await _apiService.multipart(
        ApiConfig.propertyScenes(propertyId),
        method: 'POST',
        fields: fields,
        files: files,
        requiresAuth: true,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return Scene.fromJson(data['scene'] as Map<String, dynamic>);
      } else {
        throw ApiException(response['message'] as String? ?? 'Failed to create scene');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Create scene error: $e');
    }
  }

  /// Upload images for a scene
  Future<List<SceneImage>> uploadSceneImages({
    required String sceneId,
    required List<File> images,
    String imageType = 'preview',
    int resolutionLevel = 0,
    String? face,
  }) async {
    try {
      final fields = {
        'image_type': imageType,
        'resolution_level': resolutionLevel.toString(),
        if (face != null) 'face': face,
      };

      final files = <http.MultipartFile>[];
      for (final image in images) {
        final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
        final file = await http.MultipartFile.fromPath(
          'scene_images',
          image.path,
          contentType: http.MediaType.parse(mimeType),
        );
        files.add(file);
      }

      final response = await _apiService.multipart(
        ApiConfig.sceneImages(sceneId),
        method: 'POST',
        fields: fields,
        files: files,
        requiresAuth: true,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final imagesList = data['images'] as List;
        return imagesList
            .map((i) => SceneImage.fromJson(i as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(response['message'] as String? ?? 'Failed to upload images');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Upload images error: $e');
    }
  }

  /// Create hotspot
  Future<Hotspot> createHotspot({
    required String sceneId,
    required HotspotType hotspotType,
    String? targetSceneId,
    required double yaw,
    required double pitch,
    String? title,
    String? description,
    String? iconUrl,
  }) async {
    try {
      final body = {
        'hotspot_type': hotspotType.name,
        if (targetSceneId != null) 'target_scene_id': targetSceneId,
        'yaw': yaw,
        'pitch': pitch,
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (iconUrl != null) 'icon_url': iconUrl,
      };

      final response = await _apiService.post(
        ApiConfig.sceneHotspots(sceneId),
        body: body,
        requiresAuth: true,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return Hotspot.fromJson(data['hotspot'] as Map<String, dynamic>);
      } else {
        throw ApiException(response['message'] as String? ?? 'Failed to create hotspot');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Create hotspot error: $e');
    }
  }

  /// Delete scene
  Future<void> deleteScene(String sceneId) async {
    try {
      final response = await _apiService.delete(
        ApiConfig.sceneById(sceneId),
        requiresAuth: true,
      );

      if (response['success'] != true) {
        throw ApiException(response['message'] as String? ?? 'Failed to delete scene');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Delete scene error: $e');
    }
  }

  void dispose() {
    _apiService.dispose();
  }
}

