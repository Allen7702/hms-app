import 'package:json_annotation/json_annotation.dart';

part 'expense.g.dart';

@JsonSerializable()
class Expense {
  final int id;
  @JsonKey(name: 'hotel_id')
  final int? hotelId;
  @JsonKey(name: 'category_id')
  final int? categoryId;
  @JsonKey(name: 'recurring_id')
  final int? recurringId;
  @JsonKey(name: 'maintenance_id')
  final int? maintenanceId;
  final String? title;
  final int? amount;
  @JsonKey(name: 'expense_date')
  final String? expenseDate;
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  final String? vendor;
  final String? reference;
  final String? notes;
  @JsonKey(name: 'recorded_by')
  final int? recordedBy;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const Expense({
    required this.id,
    this.hotelId,
    this.categoryId,
    this.recurringId,
    this.maintenanceId,
    this.title,
    this.amount,
    this.expenseDate,
    this.paymentMethod,
    this.vendor,
    this.reference,
    this.notes,
    this.recordedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseToJson(this);
}
