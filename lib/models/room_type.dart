import 'package:json_annotation/json_annotation.dart';

part 'room_type.g.dart';

@JsonSerializable()
class RoomType {
  final int id;
  final String? name;
  final String? description;
  final int? capacity;
  final num? price;
  @JsonKey(name: 'price_modifier')
  final num? priceModifier;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const RoomType({
    required this.id,
    this.name,
    this.description,
    this.capacity,
    this.price,
    this.priceModifier,
    this.createdAt,
    this.updatedAt,
  });

  factory RoomType.fromJson(Map<String, dynamic> json) => _$RoomTypeFromJson(json);
  Map<String, dynamic> toJson() => _$RoomTypeToJson(this);
}
