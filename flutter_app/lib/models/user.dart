import 'package:equatable/equatable.dart';

/// User types enum
enum UserType {
  buyer,
  seller,
  admin;

  String get displayName {
    switch (this) {
      case UserType.buyer:
        return 'Buyer';
      case UserType.seller:
        return 'Seller';
      case UserType.admin:
        return 'Admin';
    }
  }
}

/// User model
class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final UserType userType;
  final String? companyName;
  final bool isVerified;
  final String? profileImage;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.userType,
    this.companyName,
    required this.isVerified,
    this.profileImage,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String?,
      userType: UserType.values.firstWhere(
        (e) => e.name == json['user_type'],
        orElse: () => UserType.buyer,
      ),
      companyName: json['company_name'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      profileImage: json['profile_image'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'user_type': userType.name,
      'company_name': companyName,
      'is_verified': isVerified,
      'profile_image': profileImage,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        phone,
        userType,
        companyName,
        isVerified,
        profileImage,
        createdAt,
      ];
}

/// Authentication response model
class AuthResponse {
  final User user;
  final String token;

  const AuthResponse({
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }
}

