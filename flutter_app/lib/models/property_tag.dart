import 'package:equatable/equatable.dart';

class PropertyTag extends Equatable {
  final String name;
  final int propertyCount;

  const PropertyTag({required this.name, required this.propertyCount});

  factory PropertyTag.fromJson(Map<String, dynamic> json) {
    return PropertyTag(
      name: json['tag_name'] as String,
      propertyCount: json['property_count'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [name, propertyCount];
}
