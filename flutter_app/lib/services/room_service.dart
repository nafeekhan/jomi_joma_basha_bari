import '../models/room.dart';
import '../config/api_config.dart';
import 'api_service.dart';

/// Service for room-related API calls
class RoomService {
  final ApiService _apiService;

  RoomService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  /// Get all rooms for a property (with viewpoints)
  Future<List<Room>> getRoomsByProperty(String propertyId) async {
    try {
      final response = await _apiService.get(ApiConfig.roomsByProperty(propertyId));

      if (response['success'] == true && response['data'] != null) {
        final roomsJson = response['data']['rooms'] as List<dynamic>;
        return roomsJson
            .map((json) => Room.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ApiException(response['message'] as String? ?? 'Failed to load rooms');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Get rooms error: $e');
    }
  }

  /// Get a single room by ID
  Future<Room> getRoomById(String roomId) async {
    try {
      final response = await _apiService.get(ApiConfig.roomById(roomId));

      if (response['success'] == true && response['data'] != null) {
        return Room.fromJson(response['data']['room'] as Map<String, dynamic>);
      } else {
        throw ApiException(response['message'] as String? ?? 'Failed to load room');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Get room error: $e');
    }
  }

  /// Create a new room
  Future<Room> createRoom({
    required String propertyId,
    required String roomName,
    required int roomOrder,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.roomsByProperty(propertyId),
        body: {
          'room_name': roomName,
          'room_order': roomOrder,
        },
        requiresAuth: true,
      );

      if (response['success'] == true && response['data'] != null) {
        return Room.fromJson(response['data']['room'] as Map<String, dynamic>);
      } else {
        throw ApiException(response['message'] as String? ?? 'Failed to create room');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Create room error: $e');
    }
  }

  /// Update a room
  Future<Room> updateRoom({
    required String roomId,
    String? roomName,
    int? roomOrder,
    String? defaultViewpointId,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (roomName != null) body['room_name'] = roomName;
      if (roomOrder != null) body['room_order'] = roomOrder;
      if (defaultViewpointId != null) body['default_viewpoint_id'] = defaultViewpointId;

      final response = await _apiService.put(
        ApiConfig.roomById(roomId),
        body: body,
        requiresAuth: true,
      );

      if (response['success'] == true && response['data'] != null) {
        return Room.fromJson(response['data']['room'] as Map<String, dynamic>);
      } else {
        throw ApiException(response['message'] as String? ?? 'Failed to update room');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Update room error: $e');
    }
  }

  /// Delete a room
  Future<void> deleteRoom(String roomId) async {
    try {
      final response = await _apiService.delete(
        ApiConfig.roomById(roomId),
        requiresAuth: true,
      );

      if (response['success'] != true) {
        throw ApiException(response['message'] as String? ?? 'Failed to delete room');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Delete room error: $e');
    }
  }

  /// Set default viewpoint for a room
  Future<Room> setDefaultViewpoint({
    required String roomId,
    required String viewpointId,
  }) async {
    try {
      final response = await _apiService.put(
        ApiConfig.roomDefaultViewpoint(roomId),
        body: {
          'viewpoint_id': viewpointId,
        },
        requiresAuth: true,
      );

      if (response['success'] == true && response['data'] != null) {
        return Room.fromJson(response['data']['room'] as Map<String, dynamic>);
      } else {
        throw ApiException(response['message'] as String? ?? 'Failed to set default viewpoint');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Set default viewpoint error: $e');
    }
  }
}
