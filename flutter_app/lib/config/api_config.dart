/// API Configuration for Real Estate Platform
class ApiConfig {
  // Base URL - change this to your backend server URL
  static const String baseUrl = 'http://localhost:3000';
  
  // API Endpoints
  static const String apiBase = '$baseUrl/api';
  
  // Auth endpoints
  static const String login = '$apiBase/auth/login';
  static const String register = '$apiBase/auth/register';
  static const String getMe = '$apiBase/auth/me';
  
  // Property endpoints
  static const String properties = '$apiBase/properties';
  static String propertyById(String id) => '$properties/$id';
  static String propertyScenes(String propertyId) => '$properties/$propertyId/scenes';
  static const String propertyTags = '$properties/tags';
  static const String propertyVendors = '$properties/vendors';
  
  // Scene endpoints
  static const String scenes = '$apiBase/scenes';
  static String sceneById(String id) => '$scenes/$id';
  static String sceneImages(String sceneId) => '$scenes/$sceneId/images';
  static String sceneHotspots(String sceneId) => '$scenes/$sceneId/hotspots';

  // Room endpoints
  static const String rooms = '$apiBase/rooms';
  static String roomsByProperty(String propertyId) => '$rooms/properties/$propertyId/rooms';
  static String roomById(String roomId) => '$rooms/$roomId';
  static String roomDefaultViewpoint(String roomId) => '$rooms/$roomId/default-viewpoint';
  
  // Viewer endpoint
  static String viewerUrl(String propertyId) => '$baseUrl/viewer?propertyId=$propertyId';
  
  // File upload
  static const String uploadImages = '$apiBase/upload/images';
  
  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
