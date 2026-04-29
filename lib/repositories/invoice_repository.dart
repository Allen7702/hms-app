import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:hms_app/config/supabase_config.dart';
import 'package:hms_app/local_db/app_database.dart';
import 'package:hms_app/local_db/extensions/local_to_model.dart';
import 'package:hms_app/local_db/mappers/local_mappers.dart';
import 'package:hms_app/models/charge.dart';
import 'package:hms_app/models/invoice.dart';
import 'package:hms_app/models/payment.dart';
import 'package:hms_app/services/connectivity_service.dart';

class InvoiceRepository {
  final AppDatabase _db;
  final ConnectivityService _connectivity;
  final _client = SupabaseConfig.client;

  InvoiceRepository(this._db, this._connectivity);

  Future<List<Invoice>> getAll({String? status}) async {
    var rows = await _db.billingDao.getAllInvoices();
    if (status != null) rows = rows.where((r) => r.status == status).toList();
    rows.sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
    return rows.map((r) => r.toModel()).toList();
  }

  Future<Invoice?> getById(int id) async {
    final row = await _db.billingDao.getInvoiceById(id);
    return row?.toModel();
  }

  Future<List<Invoice>> getByBookingId(int bookingId) async {
    final rows = await _db.billingDao.getInvoicesByBooking(bookingId);
    return rows.map((r) => r.toModel()).toList();
  }

  Future<Invoice> create(Map<String, dynamic> data) async {
    _requireOnline();
    final response = await _client.from('invoices').insert(data).select().single();
    await _db.billingDao.upsertInvoice(invoiceFromMap(response));
    return Invoice.fromJson(response);
  }

  Future<Invoice> update(int id, Map<String, dynamic> data) async {
    final now = DateTime.now().toIso8601String();
    final payload = {...data, 'id': id, 'updated_at': now};

    await _db.billingDao.upsertInvoice(invoiceFromMap(payload));

    if (_connectivity.isOnline) {
      final response =
          await _client.from('invoices').update(data).eq('id', id).select().single();
      return Invoice.fromJson(response);
    } else {
      await _enqueue('invoices', 'update', id, payload);
      return (await _db.billingDao.getInvoiceById(id))!.toModel();
    }
  }

  Future<List<Invoice>> getUnpaidByBookingId(int bookingId) async {
    final rows = await _db.billingDao.getInvoicesByBooking(bookingId);
    return rows
        .where((r) => r.status == 'Unpaid' || r.status == 'Draft')
        .map((r) => r.toModel())
        .toList();
  }

  Future<void> _enqueue(String table, String op, int id, Map<String, dynamic> payload) =>
      _db.syncDao.enqueue(SyncQueueTableCompanion(
        entityTable: Value(table),
        operation: Value(op),
        recordId: Value(id),
        payload: Value(jsonEncode(payload)),
        createdAt: Value(DateTime.now().toIso8601String()),
      ));

  void _requireOnline() {
    if (!_connectivity.isOnline) {
      throw Exception('This action requires an internet connection.');
    }
  }
}

class ChargeRepository {
  final AppDatabase _db;
  final ConnectivityService _connectivity;
  final _client = SupabaseConfig.client;

  ChargeRepository(this._db, this._connectivity);

  Future<List<Charge>> getByBookingId(int bookingId) async {
    final rows = await _db.billingDao.getChargesByBooking(bookingId);
    return rows.map((r) => r.toModel()).toList();
  }

  Future<Charge> create(Map<String, dynamic> data) async {
    if (!_connectivity.isOnline) throw Exception('This action requires an internet connection.');
    final response = await _client.from('charges').insert(data).select().single();
    await _db.billingDao.upsertCharge(chargeFromMap(response));
    return Charge.fromJson(response);
  }

  Future<Charge> update(int id, Map<String, dynamic> data) async {
    final now = DateTime.now().toIso8601String();
    final payload = {...data, 'id': id, 'updated_at': now};
    await _db.billingDao.upsertCharge(chargeFromMap(payload));

    if (_connectivity.isOnline) {
      final response =
          await _client.from('charges').update(data).eq('id', id).select().single();
      return Charge.fromJson(response);
    } else {
      await _db.syncDao.enqueue(SyncQueueTableCompanion(
        entityTable: const Value('charges'),
        operation: const Value('update'),
        recordId: Value(id),
        payload: Value(jsonEncode(payload)),
        createdAt: Value(now),
      ));
      final rows = await _db.billingDao.getChargesByBooking(payload['booking_id'] as int? ?? 0);
      return rows.firstWhere((r) => r.id == id).toModel();
    }
  }

  Future<List<Charge>> getPendingByBookingId(int bookingId) async {
    final rows = await _db.billingDao.getChargesByBooking(bookingId);
    return rows.where((r) => r.status == 'Pending').map((r) => r.toModel()).toList();
  }
}

class PaymentRepository {
  final AppDatabase _db;
  final ConnectivityService _connectivity;
  final _client = SupabaseConfig.client;

  PaymentRepository(this._db, this._connectivity);

  Future<List<Payment>> getByInvoiceId(int invoiceId) async {
    final rows = await _db.billingDao.getPaymentsByInvoice(invoiceId);
    return rows.map((r) => r.toModel()).toList();
  }

  Future<Payment> create(Map<String, dynamic> data) async {
    if (!_connectivity.isOnline) throw Exception('This action requires an internet connection.');
    final response = await _client.from('payments').insert(data).select().single();
    await _db.billingDao.upsertPayment(paymentFromMap(response));
    return Payment.fromJson(response);
  }
}
