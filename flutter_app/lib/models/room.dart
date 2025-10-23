import 'package:equatable/equatable.dart';
import 'scene.dart';

/// Room model - represents a physical room with multiple viewpoints
class Room extends Equatable {
  final String? id;
  final String propertyId;
  final String roomName;
  final int roomOrder;
  final String? defaultViewpointId;
  final DateTime? createdAt;
  
  // Viewpoints (scenes) within this room
  final List<Scene>? viewpoints;

  const Room({
    this.id,
    required this.propertyId,
    required this.roomName,
    required this.roomOrder,
    this.defaultViewpointId,
    this.createdAt,
    this.viewpoints,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String?,
      propertyId: json['property_id'] as String,
      roomName: json['room_name'] as String,
      roomOrder: json['room_order'] as int,
      defaultViewpointId: json['default_viewpoint_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      viewpoints: json['viewpoints'] != null
          ? (json['viewpoints'] as List)
              .map((v) => Scene.fromJson(v as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'property_id': propertyId,
      'room_name': roomName,
      'room_order': roomOrder,
      'default_viewpoint_id': defaultViewpointId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  Room copyWith({
    String? id,
    String? propertyId,
    String? roomName,
    int? roomOrder,
    String? defaultViewpointId,
    DateTime? createdAt,
    List<Scene>? viewpoints,
  }) {
    return Room(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      roomName: roomName ?? this.roomName,
      roomOrder: roomOrder ?? this.roomOrder,
      defaultViewpointId: defaultViewpointId ?? this.defaultViewpointId,
      createdAt: createdAt ?? this.createdAt,
      viewpoints: viewpoints ?? this.viewpoints,
    );
  }

  /// Get the default viewpoint for this room
  Scene? getDefaultViewpoint() {
    if (viewpoints == null || viewpoints!.isEmpty) return null;
    
    if (defaultViewpointId != null) {
      return viewpoints!.firstWhere(
        (v) => v.id == defaultViewpointId,
        orElse: () => viewpoints!.first,
      );
    }
    
    return viewpoints!.firstWhere(
      (v) => v.isDefaultViewpoint,
      orElse: () => viewpoints!.first,
    );
  }

  /// Check if this room has multiple viewpoints
  bool hasMultipleViewpoints() {
    return viewpoints != null && viewpoints!.length > 1;
  }

  @override
  List<Object?> get props => [
        id,
        propertyId,
        roomName,
        roomOrder,
        defaultViewpointId,
        createdAt,
      ];
}

/// Temporary room upload data (before creation)
class RoomUploadData {
  String? id;
  String name;
  int order;
  List<ViewpointUploadData> viewpoints;
  String? defaultViewpointId;

  RoomUploadData({
    this.id,
    required this.name,
    required this.order,
    List<ViewpointUploadData>? viewpoints,
    this.defaultViewpointId,
  }) : viewpoints = viewpoints ?? [];
}

/// Temporary viewpoint upload data
class ViewpointUploadData {
  String? id;
  String name;
  List<String> imagePaths;
  bool isDefault;

  ViewpointUploadData({
    this.id,
    required this.name,
    List<String>? imagePaths,
    this.isDefault = false,
  }) : imagePaths = imagePaths ?? [];
}

