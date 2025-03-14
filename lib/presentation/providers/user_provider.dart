import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cart_task/domain/entities/user.dart';
import 'package:cart_task/domain/repositories/user_repository.dart';

// Provider for the user repository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  // This will be overridden in the DISetup widget
  throw UnimplementedError('UserRepository provider not implemented');
});

// Provider for the current user
final currentUserProvider = StateProvider<User?>((ref) => null);

// Provider for getting a user by ID
final userByIdProvider = FutureProvider.family<User, int>(
  (ref, id) async {
    final repository = ref.watch(userRepositoryProvider);
    return repository.getUser(id);
  },
);

// Provider for all users
final allUsersProvider = FutureProvider<List<User>>(
  (ref) async {
    final repository = ref.watch(userRepositoryProvider);
    return repository.getAllUsers();
  },
);

// Notifier for user operations
class UserNotifier extends StateNotifier<AsyncValue<User?>> {
  final UserRepository _repository;

  UserNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> createUser(User user) async {
    state = const AsyncValue.loading();
    try {
      final createdUser = await _repository.createUser(user);
      state = AsyncValue.data(createdUser);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateUser(User user) async {
    state = const AsyncValue.loading();
    try {
      final updatedUser = await _repository.updateUser(user);
      state = AsyncValue.data(updatedUser);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteUser(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteUser(id);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final userNotifierProvider = StateNotifierProvider<UserNotifier, AsyncValue<User?>>(
  (ref) => UserNotifier(ref.watch(userRepositoryProvider)),
);