import 'package:drift/drift.dart';
import '../app_database.dart';

part 'booking_dao.g.dart';

@DriftAccessor(tables: [BookingsTable, OtaReservationsTable])
class BookingDao extends DatabaseAccessor<AppDatabase> with _$BookingDaoMixin {
  BookingDao(super.db);

  // ─── Bookings ──────────────────────────────────────────────────────────────

  Stream<List<LocalBooking>> watchAllBookings() => select(bookingsTable).watch();
  Future<List<LocalBooking>> getAllBookings() => select(bookingsTable).get();

  Future<LocalBooking?> getBookingById(int id) =>
      (select(bookingsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<LocalBooking>> getBookingsByStatus(String status) =>
      (select(bookingsTable)..where((t) => t.status.equals(status))).get();

  Future<List<LocalBooking>> getTodayArrivals(String todayDate) =>
      (select(bookingsTable)
            ..where((t) =>
                t.checkIn.like('$todayDate%') &
                t.status.isIn(['Confirmed', 'Pending'])))
          .get();

  Future<List<LocalBooking>> getTodayDepartures(String todayDate) =>
      (select(bookingsTable)
            ..where((t) =>
                t.checkOut.like('$todayDate%') &
                t.status.equals('CheckedIn')))
          .get();

  Future<void> upsertBooking(BookingsTableCompanion c) =>
      into(bookingsTable).insertOnConflictUpdate(c);

  Future<void> upsertAllBookings(List<BookingsTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(bookingsTable, rows));

  Future<int> deleteBooking(int id) =>
      (delete(bookingsTable)..where((t) => t.id.equals(id))).go();

  Future<void> clearBookings() => delete(bookingsTable).go();

  // ─── OTA Reservations ──────────────────────────────────────────────────────

  Future<List<LocalOtaReservation>> getAllOtaReservations() =>
      select(otaReservationsTable).get();

  Future<LocalOtaReservation?> getOtaByBookingId(int bookingId) =>
      (select(otaReservationsTable)
            ..where((t) => t.bookingId.equals(bookingId)))
          .getSingleOrNull();

  Future<void> upsertOtaReservation(OtaReservationsTableCompanion c) =>
      into(otaReservationsTable).insertOnConflictUpdate(c);

  Future<void> upsertAllOtaReservations(
          List<OtaReservationsTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(otaReservationsTable, rows));

  Future<void> clearOtaReservations() => delete(otaReservationsTable).go();
}
