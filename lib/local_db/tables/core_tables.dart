import 'package:drift/drift.dart';

// ─── Users ────────────────────────────────────────────────────────────────────

@DataClassName('LocalUser')
class UsersTable extends Table {
  @override
  String get tableName => 'users';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get hotelId => integer().nullable().named('hotel_id')();
  TextColumn get fullName => text().nullable().named('full_name')();
  TextColumn get username => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get role => text().nullable()();
  BoolColumn get isActive => boolean().nullable().named('is_active')();
  TextColumn get createdAt => text().nullable().named('created_at')();
  TextColumn get updatedAt => text().nullable().named('updated_at')();
}

// ─── Hotels ───────────────────────────────────────────────────────────────────

@DataClassName('LocalHotel')
class HotelsTable extends Table {
  @override
  String get tableName => 'hotels';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  TextColumn get name => text().nullable()();
  TextColumn get logoUrl => text().nullable().named('logo_url')();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get website => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get settings => text().nullable()(); // JSON string
  BoolColumn get isActive => boolean().nullable().named('is_active')();
  TextColumn get createdAt => text().nullable().named('created_at')();
  TextColumn get updatedAt => text().nullable().named('updated_at')();
}

// ─── Room Types ───────────────────────────────────────────────────────────────

@DataClassName('LocalRoomType')
class RoomTypesTable extends Table {
  @override
  String get tableName => 'room_types';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get hotelId => integer().nullable().named('hotel_id')();
  TextColumn get name => text().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get capacity => integer().nullable()();
  IntColumn get price => integer().nullable()();
  IntColumn get priceModifier => integer().nullable().named('price_modifier')();
  TextColumn get createdAt => text().nullable().named('created_at')();
  TextColumn get updatedAt => text().nullable().named('updated_at')();
}

// ─── Rooms ────────────────────────────────────────────────────────────────────

@DataClassName('LocalRoom')
class RoomsTable extends Table {
  @override
  String get tableName => 'rooms';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get hotelId => integer().nullable().named('hotel_id')();
  TextColumn get roomNumber => text().nullable().named('room_number')();
  TextColumn get floor => text().nullable()();
  IntColumn get roomTypeId => integer().nullable().named('room_type_id')();
  TextColumn get status => text().nullable()();
  TextColumn get features => text().nullable()(); // JSON string
  TextColumn get lastCleaned => text().nullable().named('last_cleaned')();
  TextColumn get createdAt => text().nullable().named('created_at')();
  TextColumn get updatedAt => text().nullable().named('updated_at')();
}

// ─── Guests ───────────────────────────────────────────────────────────────────

@DataClassName('LocalGuest')
class GuestsTable extends Table {
  @override
  String get tableName => 'guests';
  @override
  Set<Column> get primaryKey => {id};

  IntColumn get id => integer()();
  IntColumn get hotelId => integer().nullable().named('hotel_id')();
  TextColumn get name => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get nationality => text().nullable()();
  TextColumn get idNumber => text().nullable().named('id_number')();
  TextColumn get preferences => text().nullable()(); // JSON string
  IntColumn get loyaltyPoints => integer().nullable().named('loyalty_points')();
  TextColumn get loyaltyTier => text().nullable().named('loyalty_tier')();
  BoolColumn get gdprConsent => boolean().nullable().named('gdpr_consent')();
  IntColumn get totalStays => integer().nullable().named('total_stays')();
  IntColumn get totalSpent => integer().nullable().named('total_spent')();
  TextColumn get lastStayDate => text().nullable().named('last_stay_date')();
  TextColumn get preferredRoomType =>
      text().nullable().named('preferred_room_type')();
  TextColumn get notes => text().nullable()();
  IntColumn get userId => integer().nullable().named('user_id')();
  TextColumn get createdAt => text().nullable().named('created_at')();
  TextColumn get updatedAt => text().nullable().named('updated_at')();
}
