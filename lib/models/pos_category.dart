import 'package:json_annotation/json_annotation.dart';

part 'pos_category.g.dart';

@JsonSerializable()
class PosCategory {
  final int id;
  @JsonKey(name: 'hotel_id')
  final int? hotelId;
  final String? name;
  final String? color;
  @JsonKey(name: 'sort_order')
  final int? sortOrder;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const PosCategory({
    required this.id,
    this.hotelId,
    this.name,
    this.color,
    this.sortOrder,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory PosCategory.fromJson(Map<String, dynamic> json) =>
      _$PosCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$PosCategoryToJson(this);
}
