import 'package:drift/drift.dart';

// ─── Bookings ─────────────────────────────────────────────────────────────────

@DataClassName('LocalBooking')
class BookingsTable extends Table {
  @override
  String get tableName => 'bookings';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get guestId => integer().nullable().named('guest_id')();
  IntColumn get roomId => integer().nullable().named('room_id')();
  TextColumn get checkIn => text().nullable().named('check_in')();
  TextColumn get checkOut => text().nullable().named('check_out')();
  TextColumn get status => text().nullable()();
  TextColumn get source => text().nullable()();
  IntColumn get rateApplied => integer().nullable().named('rate_applied')();
  IntColumn get adults => integer().nullable()();
  IntColumn get children => integer().nullable()();
  TextColumn get specialRequests => text().nullable().named('special_requests')();
  TextColumn get notes => text().nullable()();
  TextColumn get modificationReason => text().nullable().named('modification_reason')();
  TextColumn get paymentStatus => text().nullable().named('payment_status')();
  TextColumn get createdAt => text().nullable().named('created_at')();
  TextColumn get updatedAt => text().nullable().named('updated_at')();
}

// ─── OTA Reservations ─────────────────────────────────────────────────────────

@DataClassName('LocalOtaReservation')
class OtaReservationsTable extends Table {
  @override
  String get tableName => 'ota_reservations';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get bookingId => integer().nullable().named('booking_id')();
  TextColumn get otaId => text().nullable().named('ota_id')();
  TextColumn get otaName => text().nullable().named('ota_name')();
  TextColumn get createdAt => text().nullable().named('created_at')();
  TextColumn get updatedAt => text().nullable().named('updated_at')();
}
