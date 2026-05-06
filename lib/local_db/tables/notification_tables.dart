import 'package:drift/drift.dart';

// ─── Notifications ────────────────────────────────────────────────────────────

@DataClassName('LocalNotification')
class NotificationsTable extends Table {
  @override
  String get tableName => 'notifications';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get hotelId => integer().nullable().named('hotel_id')();
  TextColumn get type => text().nullable()();
  IntColumn get guestId => integer().nullable().named('guest_id')();
  IntColumn get userId => integer().nullable().named('user_id')();
  TextColumn get recipient => text().nullable()();
  TextColumn get message => text().nullable()();
  TextColumn get status => text().nullable()();
  IntColumn get relatedEntityId =>
      integer().nullable().named('related_entity_id')();
  TextColumn get entityType => text().nullable().named('entity_type')();
  TextColumn get readAt => text().nullable().named('read_at')();
  TextColumn get createdAt => text().nullable().named('created_at')();
  TextColumn get updatedAt => text().nullable().named('updated_at')();
}

// ─── Device Tokens ────────────────────────────────────────────────────────────

@DataClassName('LocalDeviceToken')
class DeviceTokensTable extends Table {
  @override
  String get tableName => 'device_tokens';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get hotelId => integer().nullable().named('hotel_id')();
  IntColumn get userId => integer().nullable().named('user_id')();
  TextColumn get token => text().nullable()();
  TextColumn get platform => text().nullable()();
  TextColumn get createdAt => text().nullable().named('created_at')();
  TextColumn get updatedAt => text().nullable().named('updated_at')();
}

// ─── Audit Logs ───────────────────────────────────────────────────────────────

@DataClassName('LocalAuditLog')
class AuditLogsTable extends Table {
  @override
  String get tableName => 'audit_logs';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get hotelId => integer().nullable().named('hotel_id')();
  TextColumn get action => text().nullable()();
  IntColumn get userId => integer().nullable().named('user_id')();
  TextColumn get entityType => text().nullable().named('entity_type')();
  IntColumn get entityId => integer().nullable().named('entity_id')();
  TextColumn get details => text().nullable()(); // JSON
  TextColumn get dataBefore => text().nullable().named('data_before')(); // JSON
  TextColumn get dataAfter => text().nullable().named('data_after')(); // JSON
  TextColumn get createdAt => text().nullable().named('created_at')();
  TextColumn get updatedAt => text().nullable().named('updated_at')();
}
