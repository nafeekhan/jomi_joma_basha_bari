import 'package:equatable/equatable.dart';

/// Hotspot type enum
enum HotspotType {
  navigation,
  info;

  String get displayName {
    switch (this) {
      case HotspotType.navigation:
        return 'Navigation';
      case HotspotType.info:
        return 'Information';
    }
  }
}

/// Scene image model
class SceneImage extends Equatable {
  final String id;
  final String imageType;
  final int? resolutionLevel;
  final String? face;
  final int? tileX;
  final int? tileY;
  final String filePath;
  final int? fileSize;

  const SceneImage({
    required this.id,
    required this.imageType,
    this.resolutionLevel,
    this.face,
    this.tileX,
    this.tileY,
    required this.filePath,
    this.fileSize,
  });

  factory SceneImage.fromJson(Map<String, dynamic> json) {
    return SceneImage(
      id: json['id'] as String,
      imageType: json['image_type'] as String,
      resolutionLevel: json['resolution_level'] as int?,
      face: json['face'] as String?,
      tileX: json['tile_x'] as int?,
      tileY: json['tile_y'] as int?,
      filePath: json['file_path'] as String,
      fileSize: json['file_size'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_type': imageType,
      'resolution_level': resolutionLevel,
      'face': face,
      'tile_x': tileX,
      'tile_y': tileY,
      'file_path': filePath,
      'file_size': fileSize,
    };
  }

  @override
  List<Object?> get props => [id, imageType, resolutionLevel, face, tileX, tileY, filePath, fileSize];
}

/// Hotspot model
class Hotspot extends Equatable {
  final String id;
  final String sceneId;
  final HotspotType hotspotType;
  final String? targetSceneId;
  final String? targetSceneName;
  final double yaw;
  final double pitch;
  final String? title;
  final String? description;
  final String? iconUrl;

  const Hotspot({
    required this.id,
    required this.sceneId,
    required this.hotspotType,
    this.targetSceneId,
    this.targetSceneName,
    required this.yaw,
    required this.pitch,
    this.title,
    this.description,
    this.iconUrl,
  });

  factory Hotspot.fromJson(Map<String, dynamic> json) {
    return Hotspot(
      id: json['id'] as String,
      sceneId: json['scene_id'] as String,
      hotspotType: HotspotType.values.firstWhere(
        (e) => e.name == json['hotspot_type'],
        orElse: () => HotspotType.info,
      ),
      targetSceneId: json['target_scene_id'] as String?,
      targetSceneName: json['target_scene_name'] as String?,
      yaw: (json['yaw'] as num).toDouble(),
      pitch: (json['pitch'] as num).toDouble(),
      title: json['title'] as String?,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scene_id': sceneId,
      'hotspot_type': hotspotType.name,
      'target_scene_id': targetSceneId,
      'yaw': yaw,
      'pitch': pitch,
      'title': title,
      'description': description,
      'icon_url': iconUrl,
    };
  }

  @override
  List<Object?> get props => [
        id,
        sceneId,
        hotspotType,
        targetSceneId,
        targetSceneName,
        yaw,
        pitch,
        title,
        description,
        iconUrl,
      ];
}

/// Scene model (for 360 tour rooms/scenes)
class Scene extends Equatable {
  final String id;
  final String propertyId;
  final String sceneName;
  final int sceneOrder;
  final double initialViewYaw;
  final double initialViewPitch;
  final double initialViewFov;
  final DateTime createdAt;
  final String? roomId;
  final String? viewpointName;
  final bool isDefaultViewpoint;

  // Additional fields loaded lazily or injected locally
  final List<SceneImage>? images;
  final List<Hotspot>? hotspots;
  final List<String>? _localImagePaths;

  const Scene({
    required this.id,
    required this.propertyId,
    required this.sceneName,
    required this.sceneOrder,
    required this.initialViewYaw,
    required this.initialViewPitch,
    required this.initialViewFov,
    required this.createdAt,
    this.roomId,
    this.viewpointName,
    this.isDefaultViewpoint = false,
    this.images,
    this.hotspots,
    List<String>? localImagePaths,
  }) : _localImagePaths = localImagePaths;

  /// Convenience constructor for local-only scenes (e.g. upload drafts)
  factory Scene.localDraft({
    required String id,
    required String name,
    required int sceneOrder,
    List<String>? imagePaths,
    bool isDefaultViewpoint = false,
  }) {
    return Scene(
      id: id,
      propertyId: '',
      sceneName: name,
      sceneOrder: sceneOrder,
      initialViewYaw: 0.0,
      initialViewPitch: 0.0,
      initialViewFov: 1.5708,
      createdAt: DateTime.now(),
      viewpointName: name,
      isDefaultViewpoint: isDefaultViewpoint,
      localImagePaths: imagePaths,
      hotspots: const [],
    );
  }

  String get name => viewpointName ?? sceneName;

  List<String> get imagePaths {
    final localPaths = _localImagePaths;
    if (localPaths != null) {
      return localPaths;
    }
    final remoteImages = images;
    if (remoteImages != null) {
      return remoteImages.map((image) => image.filePath).toList();
    }
    return const [];
  }

  factory Scene.fromJson(Map<String, dynamic> json) {
    return Scene(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      sceneName: json['scene_name'] as String,
      sceneOrder: json['scene_order'] as int,
      initialViewYaw: (json['initial_view_yaw'] as num?)?.toDouble() ?? 0.0,
      initialViewPitch: (json['initial_view_pitch'] as num?)?.toDouble() ?? 0.0,
      initialViewFov: (json['initial_view_fov'] as num?)?.toDouble() ?? 1.5708,
      createdAt: DateTime.parse(json['created_at'] as String),
      roomId: json['room_id'] as String?,
      viewpointName: json['viewpoint_name'] as String?,
      isDefaultViewpoint: json['is_default_viewpoint'] as bool? ?? false,
      images: json['images'] != null
          ? (json['images'] as List).map((i) => SceneImage.fromJson(i as Map<String, dynamic>)).toList()
          : null,
      hotspots: json['hotspots'] != null
          ? (json['hotspots'] as List).map((h) => Hotspot.fromJson(h as Map<String, dynamic>)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'scene_name': sceneName,
      'scene_order': sceneOrder,
      'initial_view_yaw': initialViewYaw,
      'initial_view_pitch': initialViewPitch,
      'initial_view_fov': initialViewFov,
      'created_at': createdAt.toIso8601String(),
      if (roomId != null) 'room_id': roomId,
      if (viewpointName != null) 'viewpoint_name': viewpointName,
      'is_default_viewpoint': isDefaultViewpoint,
    };
  }

  Scene copyWith({
    List<SceneImage>? images,
    List<Hotspot>? hotspots,
  }) {
    return Scene(
      id: id,
      propertyId: propertyId,
      sceneName: sceneName,
      sceneOrder: sceneOrder,
      initialViewYaw: initialViewYaw,
      initialViewPitch: initialViewPitch,
      initialViewFov: initialViewFov,
      createdAt: createdAt,
      roomId: roomId,
      viewpointName: viewpointName,
      isDefaultViewpoint: isDefaultViewpoint,
      images: images ?? this.images,
      hotspots: hotspots ?? this.hotspots,
      localImagePaths: _localImagePaths,
    );
  }

  @override
  List<Object?> get props => [
        id,
        propertyId,
        sceneName,
        sceneOrder,
        initialViewYaw,
        initialViewPitch,
        initialViewFov,
        createdAt,
        roomId,
        viewpointName,
        isDefaultViewpoint,
        _localImagePaths,
      ];
}
