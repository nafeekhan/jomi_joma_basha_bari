import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/room.dart';
import '../config/api_config.dart';
import 'api_service.dart';

/// Service for room-related API calls
class RoomService {
  final ApiService _apiService = ApiService();

  /// Get all rooms for a property (with viewpoints)
  Future<List<Room>> getRoomsByProperty(String propertyId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/rooms/properties/$propertyId/rooms'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final roomsJson = data['data']['rooms'] as List;
          return roomsJson.map((json) => Room.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to load rooms');
    } catch (e) {
      print('Error loading rooms: $e');
      rethrow;
    }
  }

  /// Get a single room by ID
  Future<Room> getRoomById(String roomId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/rooms/$roomId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Room.fromJson(data['data']['room']);
        }
      }
      throw Exception('Failed to load room');
    } catch (e) {
      print('Error loading room: $e');
      rethrow;
    }
  }

  /// Create a new room
  Future<Room> createRoom({
    required String propertyId,
    required String roomName,
    required int roomOrder,
    String? token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/rooms/properties/$propertyId/rooms'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'room_name': roomName,
          'room_order': roomOrder,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Room.fromJson(data['data']['room']);
        }
      }
      throw Exception('Failed to create room');
    } catch (e) {
      print('Error creating room: $e');
      rethrow;
    }
  }

  /// Update a room
  Future<Room> updateRoom({
    required String roomId,
    String? roomName,
    int? roomOrder,
    String? defaultViewpointId,
    String? token,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (roomName != null) body['room_name'] = roomName;
      if (roomOrder != null) body['room_order'] = roomOrder;
      if (defaultViewpointId != null) body['default_viewpoint_id'] = defaultViewpointId;

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/rooms/$roomId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Room.fromJson(data['data']['room']);
        }
      }
      throw Exception('Failed to update room');
    } catch (e) {
      print('Error updating room: $e');
      rethrow;
    }
  }

  /// Delete a room
  Future<void> deleteRoom(String roomId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/rooms/$roomId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete room');
      }
    } catch (e) {
      print('Error deleting room: $e');
      rethrow;
    }
  }

  /// Set default viewpoint for a room
  Future<Room> setDefaultViewpoint({
    required String roomId,
    required String viewpointId,
    required String token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/rooms/$roomId/default-viewpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'viewpoint_id': viewpointId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Room.fromJson(data['data']['room']);
        }
      }
      throw Exception('Failed to set default viewpoint');
    } catch (e) {
      print('Error setting default viewpoint: $e');
      rethrow;
    }
  }
}

