import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hms_app/models/guest.dart';
import 'package:hms_app/repositories/guest_repository.dart';

final guestRepositoryProvider = Provider((ref) => GuestRepository());

final guestsProvider = FutureProvider<List<Guest>>((ref) async {
  final repo = ref.read(guestRepositoryProvider);
  return repo.getAll();
});

final guestDetailProvider = FutureProvider.family<Guest?, int>((ref, id) async {
  final repo = ref.read(guestRepositoryProvider);
  return repo.getById(id);
});
