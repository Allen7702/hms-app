import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hms_app/models/room.dart';
import 'package:hms_app/models/room_type.dart';
import 'package:hms_app/repositories/room_repository.dart';

final roomRepositoryProvider = Provider((ref) => RoomRepository());

final roomsProvider = FutureProvider<List<Room>>((ref) async {
  final repo = ref.read(roomRepositoryProvider);
  return repo.getAll();
});

final roomDetailProvider = FutureProvider.family<Room?, int>((ref, id) async {
  final repo = ref.read(roomRepositoryProvider);
  return repo.getById(id);
});

final roomTypesProvider = FutureProvider<List<RoomType>>((ref) async {
  final repo = ref.read(roomRepositoryProvider);
  return repo.getRoomTypes();
});

final roomStatusCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repo = ref.read(roomRepositoryProvider);
  return repo.getStatusCounts();
});

final roomFloorsProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.read(roomRepositoryProvider);
  return repo.getFloors();
});
