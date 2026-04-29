import 'package:json_annotation/json_annotation.dart';

part 'expense_category.g.dart';

@JsonSerializable()
class ExpenseCategory {
  final int id;
  @JsonKey(name: 'hotel_id')
  final int? hotelId;
  final String? name;
  final String? description;
  final String? color;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const ExpenseCategory({
    required this.id,
    this.hotelId,
    this.name,
    this.description,
    this.color,
    this.createdAt,
    this.updatedAt,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) =>
      _$ExpenseCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseCategoryToJson(this);
}
