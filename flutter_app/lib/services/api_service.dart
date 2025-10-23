import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/storage_helper.dart';

/// Base API Service class
class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Get headers with authorization token
  Future<Map<String, String>> _getHeaders({bool requiresAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await StorageHelper.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  /// GET request
  Future<Map<String, dynamic>> get(
    String url, {
    bool requiresAuth = false,
    Map<String, String>? queryParameters,
  }) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParameters);
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await _client
          .get(uri, headers: headers)
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String url, {
    required Map<String, dynamic> body,
    bool requiresAuth = false,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await _client
          .post(
            Uri.parse(url),
            headers: headers,
            body: json.encode(body),
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
    String url, {
    required Map<String, dynamic> body,
    bool requiresAuth = false,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await _client
          .put(
            Uri.parse(url),
            headers: headers,
            body: json.encode(body),
          )
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(
    String url, {
    bool requiresAuth = false,
  }) async {
    try {
      final headers = await _getHeaders(requiresAuth: requiresAuth);

      final response = await _client
          .delete(Uri.parse(url), headers: headers)
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Network error: $e');
    }
  }

  /// Multipart request for file uploads
  Future<Map<String, dynamic>> multipart(
    String url, {
    required String method,
    required Map<String, String> fields,
    List<http.MultipartFile>? files,
    bool requiresAuth = false,
  }) async {
    try {
      final request = http.MultipartRequest(method, Uri.parse(url));

      // Add headers
      if (requiresAuth) {
        final token = await StorageHelper.getToken();
        if (token != null) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }

      // Add fields
      request.fields.addAll(fields);

      // Add files
      if (files != null) {
        request.files.addAll(files);
      }

      final streamedResponse = await request.send().timeout(ApiConfig.receiveTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Upload error: $e');
    }
  }

  /// Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    if (body.isEmpty) {
      if (statusCode >= 200 && statusCode < 300) {
        return {'success': true};
      } else {
        throw ApiException('Request failed with status: $statusCode');
      }
    }

    final Map<String, dynamic> data;
    try {
      data = json.decode(body) as Map<String, dynamic>;
    } catch (e) {
      throw ApiException('Invalid response format');
    }

    if (statusCode >= 200 && statusCode < 300) {
      return data;
    } else {
      final message = data['message'] as String? ?? 'Request failed';
      throw ApiException(message, statusCode: statusCode);
    }
  }

  void dispose() {
    _client.close();
  }
}

/// API Exception class
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

