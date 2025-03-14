import 'package:cart_task/domain/entities/user.dart';

abstract class UserRepository {
  // Get user by ID
  Future<User> getUser(int id);

  // Create a new user
  Future<User> createUser(User user);

  // Update existing user
  Future<User> updateUser(User user);

  // Delete user
  Future<void> deleteUser(int id);

  // Get all users
  Future<List<User>> getAllUsers();
}