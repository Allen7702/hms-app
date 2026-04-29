import 'package:json_annotation/json_annotation.dart';

part 'recurring_expense.g.dart';

@JsonSerializable()
class RecurringExpense {
  final int id;
  @JsonKey(name: 'hotel_id')
  final int? hotelId;
  @JsonKey(name: 'category_id')
  final int? categoryId;
  final String? title;
  final int? amount;
  final String? frequency;
  @JsonKey(name: 'day_of_month')
  final int? dayOfMonth;
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  final String? vendor;
  final String? notes;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'last_applied')
  final String? lastApplied;
  @JsonKey(name: 'start_date')
  final String? startDate;
  @JsonKey(name: 'end_date')
  final String? endDate;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const RecurringExpense({
    required this.id,
    this.hotelId,
    this.categoryId,
    this.title,
    this.amount,
    this.frequency,
    this.dayOfMonth,
    this.paymentMethod,
    this.vendor,
    this.notes,
    this.isActive,
    this.lastApplied,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  factory RecurringExpense.fromJson(Map<String, dynamic> json) =>
      _$RecurringExpenseFromJson(json);
  Map<String, dynamic> toJson() => _$RecurringExpenseToJson(this);
}
