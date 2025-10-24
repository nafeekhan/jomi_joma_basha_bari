import 'package:equatable/equatable.dart';

class Vendor extends Equatable {
  final String id;
  final String fullName;
  final String? companyName;
  final String? email;
  final String? phone;
  final int propertyCount;
  final double averagePrice;

  const Vendor({
    required this.id,
    required this.fullName,
    this.companyName,
    this.email,
    this.phone,
    required this.propertyCount,
    required this.averagePrice,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      companyName: json['company_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      propertyCount: json['property_count'] as int? ?? 0,
      averagePrice: json['average_price'] != null
          ? (json['average_price'] as num).toDouble()
          : 0.0,
    );
  }

  @override
  List<Object?> get props => [id, fullName, companyName, email, phone, propertyCount, averagePrice];
}
