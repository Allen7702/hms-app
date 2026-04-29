import 'package:drift/drift.dart';
import '../app_database.dart';

part 'core_dao.g.dart';

@DriftAccessor(tables: [UsersTable, HotelsTable, RoomTypesTable, RoomsTable, GuestsTable])
class CoreDao extends DatabaseAccessor<AppDatabase> with _$CoreDaoMixin {
  CoreDao(super.db);

  // ─── Users ────────────────────────────────────────────────────────────────

  Stream<List<LocalUser>> watchAllUsers() => select(usersTable).watch();
  Future<List<LocalUser>> getAllUsers() => select(usersTable).get();
  Future<LocalUser?> getUserById(int id) =>
      (select(usersTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<void> upsertUser(UsersTableCompanion c) =>
      into(usersTable).insertOnConflictUpdate(c);
  Future<void> upsertAllUsers(List<UsersTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(usersTable, rows));
  Future<int> deleteUser(int id) =>
      (delete(usersTable)..where((t) => t.id.equals(id))).go();
  Future<void> clearUsers() => delete(usersTable).go();

  // ─── Hotels ───────────────────────────────────────────────────────────────

  Stream<List<LocalHotel>> watchAllHotels() => select(hotelsTable).watch();
  Future<List<LocalHotel>> getAllHotels() => select(hotelsTable).get();
  Future<LocalHotel?> getHotelById(int id) =>
      (select(hotelsTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<void> upsertHotel(HotelsTableCompanion c) =>
      into(hotelsTable).insertOnConflictUpdate(c);
  Future<void> upsertAllHotels(List<HotelsTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(hotelsTable, rows));
  Future<void> clearHotels() => delete(hotelsTable).go();

  // ─── Room Types ───────────────────────────────────────────────────────────

  Stream<List<LocalRoomType>> watchAllRoomTypes() => select(roomTypesTable).watch();
  Future<List<LocalRoomType>> getAllRoomTypes() => select(roomTypesTable).get();
  Future<LocalRoomType?> getRoomTypeById(int id) =>
      (select(roomTypesTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<void> upsertRoomType(RoomTypesTableCompanion c) =>
      into(roomTypesTable).insertOnConflictUpdate(c);
  Future<void> upsertAllRoomTypes(List<RoomTypesTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(roomTypesTable, rows));
  Future<void> clearRoomTypes() => delete(roomTypesTable).go();

  // ─── Rooms ────────────────────────────────────────────────────────────────

  Stream<List<LocalRoom>> watchAllRooms() => select(roomsTable).watch();
  Future<List<LocalRoom>> getAllRooms() => select(roomsTable).get();
  Future<LocalRoom?> getRoomById(int id) =>
      (select(roomsTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<List<LocalRoom>> getRoomsByStatus(String status) =>
      (select(roomsTable)..where((t) => t.status.equals(status))).get();
  Future<void> upsertRoom(RoomsTableCompanion c) =>
      into(roomsTable).insertOnConflictUpdate(c);
  Future<void> upsertAllRooms(List<RoomsTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(roomsTable, rows));
  Future<int> deleteRoom(int id) =>
      (delete(roomsTable)..where((t) => t.id.equals(id))).go();
  Future<void> clearRooms() => delete(roomsTable).go();

  // ─── Guests ───────────────────────────────────────────────────────────────

  Stream<List<LocalGuest>> watchAllGuests() => select(guestsTable).watch();
  Future<List<LocalGuest>> getAllGuests() => select(guestsTable).get();
  Future<LocalGuest?> getGuestById(int id) =>
      (select(guestsTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<void> upsertGuest(GuestsTableCompanion c) =>
      into(guestsTable).insertOnConflictUpdate(c);
  Future<void> upsertAllGuests(List<GuestsTableCompanion> rows) =>
      batch((b) => b.insertAllOnConflictUpdate(guestsTable, rows));
  Future<int> deleteGuest(int id) =>
      (delete(guestsTable)..where((t) => t.id.equals(id))).go();
  Future<void> clearGuests() => delete(guestsTable).go();
}
