import 'package:cart_task/data/data_sources/local_db_service.dart';
import 'package:cart_task/domain/entities/user.dart';
import 'package:cart_task/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final LocalDBService _dbService;

  UserRepositoryImpl(this._dbService);

  @override
  Future<User> createUser(User user) async {
    final id = await _dbService.insert(LocalDBService.userTable, user.toMap());
    return user.copyWith(id: id);
  }

  @override
  Future<void> deleteUser(int id) async {
    await _dbService.delete(
      LocalDBService.userTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<User>> getAllUsers() async {
    final maps = await _dbService.query(LocalDBService.userTable);
    return maps.map((map) => User.fromMap(map)).toList();
  }

  @override
  Future<User> getUser(int id) async {
    final maps = await _dbService.query(
      LocalDBService.userTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      throw Exception('User not found');
    }

    return User.fromMap(maps.first);
  }

  @override
  Future<User> updateUser(User user) async {
    await _dbService.update(
      LocalDBService.userTable,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
    return user;
  }
}
