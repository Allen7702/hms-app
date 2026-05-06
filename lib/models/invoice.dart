import 'package:json_annotation/json_annotation.dart';

part 'invoice.g.dart';

@JsonSerializable()
class Invoice {
  final int id;
  @JsonKey(name: 'hotel_id')
  final int? hotelId;
  @JsonKey(name: 'booking_id')
  final int? bookingId;
  final num? amount;
  final num? tax;
  @JsonKey(name: 'invoice_number')
  final String? invoiceNumber;
  final String? status;
  @JsonKey(name: 'issue_date')
  final String? issueDate;
  @JsonKey(name: 'due_date')
  final String? dueDate;
  @JsonKey(name: 'paid_at')
  final String? paidAt;
  final String? notes;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const Invoice({
    required this.id,
    this.hotelId,
    this.bookingId,
    this.amount,
    this.tax,
    this.invoiceNumber,
    this.status,
    this.issueDate,
    this.dueDate,
    this.paidAt,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceToJson(this);
}
