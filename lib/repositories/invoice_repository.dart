import 'package:hms_app/config/supabase_config.dart';
import 'package:hms_app/models/invoice.dart';
import 'package:hms_app/models/charge.dart';
import 'package:hms_app/models/payment.dart';

class InvoiceRepository {
  final _client = SupabaseConfig.client;

  /// Get all invoices
  Future<List<Invoice>> getAll({String? status}) async {
    var query = _client.from('invoices').select();

    if (status != null) {
      query = query.eq('status', status);
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List).map((e) => Invoice.fromJson(e)).toList();
  }

  /// Get invoice by ID
  Future<Invoice?> getById(int id) async {
    final response = await _client
        .from('invoices')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Invoice.fromJson(response);
  }

  /// Get invoices by booking ID
  Future<List<Invoice>> getByBookingId(int bookingId) async {
    final response = await _client
        .from('invoices')
        .select()
        .eq('booking_id', bookingId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => Invoice.fromJson(e)).toList();
  }

  /// Create invoice
  Future<Invoice> create(Map<String, dynamic> data) async {
    final response = await _client
        .from('invoices')
        .insert(data)
        .select()
        .single();

    return Invoice.fromJson(response);
  }

  /// Update invoice
  Future<Invoice> update(int id, Map<String, dynamic> data) async {
    final response = await _client
        .from('invoices')
        .update(data)
        .eq('id', id)
        .select()
        .single();

    return Invoice.fromJson(response);
  }

  /// Get unpaid invoices for a booking
  Future<List<Invoice>> getUnpaidByBookingId(int bookingId) async {
    final response = await _client
        .from('invoices')
        .select()
        .eq('booking_id', bookingId)
        .inFilter('status', ['Unpaid', 'Draft']);

    return (response as List).map((e) => Invoice.fromJson(e)).toList();
  }
}

class ChargeRepository {
  final _client = SupabaseConfig.client;

  /// Get charges by booking ID
  Future<List<Charge>> getByBookingId(int bookingId) async {
    final response = await _client
        .from('charges')
        .select()
        .eq('booking_id', bookingId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => Charge.fromJson(e)).toList();
  }

  /// Create charge
  Future<Charge> create(Map<String, dynamic> data) async {
    final response = await _client
        .from('charges')
        .insert(data)
        .select()
        .single();

    return Charge.fromJson(response);
  }

  /// Update charge
  Future<Charge> update(int id, Map<String, dynamic> data) async {
    final response = await _client
        .from('charges')
        .update(data)
        .eq('id', id)
        .select()
        .single();

    return Charge.fromJson(response);
  }

  /// Get pending charges for a booking
  Future<List<Charge>> getPendingByBookingId(int bookingId) async {
    final response = await _client
        .from('charges')
        .select()
        .eq('booking_id', bookingId)
        .eq('status', 'Pending');

    return (response as List).map((e) => Charge.fromJson(e)).toList();
  }
}

class PaymentRepository {
  final _client = SupabaseConfig.client;

  /// Get payments by invoice ID
  Future<List<Payment>> getByInvoiceId(int invoiceId) async {
    final response = await _client
        .from('payments')
        .select()
        .eq('invoice_id', invoiceId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => Payment.fromJson(e)).toList();
  }

  /// Create payment
  Future<Payment> create(Map<String, dynamic> data) async {
    final response = await _client
        .from('payments')
        .insert(data)
        .select()
        .single();

    return Payment.fromJson(response);
  }
}
