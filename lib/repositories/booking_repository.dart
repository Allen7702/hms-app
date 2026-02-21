import 'package:hms_app/config/supabase_config.dart';
import 'package:hms_app/models/booking.dart';

class BookingRepository {
  final _client = SupabaseConfig.client;

  static const _selectWithRelations = '''
    *, 
    guests(*), 
    rooms(*, room_types(*))
  ''';

  /// Get all bookings with guest and room data
  Future<List<Booking>> getAll({String? status, String? search}) async {
    var query = _client.from('bookings').select(_selectWithRelations);

    if (status != null && status != 'All') {
      query = query.eq('status', status);
    }

    if (search != null && search.isNotEmpty) {
      query = query.or('id.eq.${int.tryParse(search) ?? 0},guests.full_name.ilike.%$search%');
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List).map((e) => Booking.fromJson(e)).toList();
  }

  /// Get booking by ID
  Future<Booking?> getById(int id) async {
    final response = await _client
        .from('bookings')
        .select(_selectWithRelations)
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Booking.fromJson(response);
  }

  /// Get today's arrivals
  Future<List<Booking>> getTodayArrivals() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final response = await _client
        .from('bookings')
        .select(_selectWithRelations)
        .gte('check_in', '${today}T00:00:00')
        .lt('check_in', '${today}T23:59:59')
        .inFilter('status', ['Confirmed', 'Pending'])
        .order('check_in');

    return (response as List).map((e) => Booking.fromJson(e)).toList();
  }

  /// Get today's departures
  Future<List<Booking>> getTodayDepartures() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final response = await _client
        .from('bookings')
        .select(_selectWithRelations)
        .gte('check_out', '${today}T00:00:00')
        .lt('check_out', '${today}T23:59:59')
        .eq('status', 'CheckedIn')
        .order('check_out');

    return (response as List).map((e) => Booking.fromJson(e)).toList();
  }

  /// Create a new booking
  Future<Booking> create(Map<String, dynamic> data) async {
    final response = await _client
        .from('bookings')
        .insert(data)
        .select(_selectWithRelations)
        .single();

    return Booking.fromJson(response);
  }

  /// Update a booking
  Future<Booking> update(int id, Map<String, dynamic> data) async {
    final response = await _client
        .from('bookings')
        .update(data)
        .eq('id', id)
        .select(_selectWithRelations)
        .single();

    return Booking.fromJson(response);
  }

  /// Check in a booking
  Future<Booking> checkIn(int id) async {
    return update(id, {'status': 'CheckedIn'});
  }

  /// Check out a booking
  Future<Booking> checkOut(int id) async {
    return update(id, {'status': 'CheckedOut'});
  }

  /// Cancel a booking
  Future<Booking> cancel(int id) async {
    return update(id, {'status': 'Cancelled'});
  }

  /// Get bookings by guest ID
  Future<List<Booking>> getByGuestId(int guestId) async {
    final response = await _client
        .from('bookings')
        .select(_selectWithRelations)
        .eq('guest_id', guestId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => Booking.fromJson(e)).toList();
  }

  /// Subscribe to booking changes
  Stream<List<Map<String, dynamic>>> subscribe() {
    return _client
        .from('bookings')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }
}
