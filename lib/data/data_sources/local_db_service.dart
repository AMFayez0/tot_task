import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDBService {
  static const String _databaseName = 'cart_app.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String userTable = 'users';
  static const String productTable = 'products';
  static const String cartItemTable = 'cart_items';
  static const String couponTable = 'coupons';

  // Singleton pattern
  LocalDBService._privateConstructor();
  static final LocalDBService instance = LocalDBService._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE $userTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phoneNumber TEXT
      )
    ''');

    // Create products table
    await db.execute('''
      CREATE TABLE $productTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        imageUrl TEXT NOT NULL
      )
    ''');

    // Create cart_items table
    await db.execute('''
      CREATE TABLE $cartItemTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES $userTable (id) ON DELETE CASCADE,
        FOREIGN KEY (productId) REFERENCES $productTable (id) ON DELETE CASCADE
      )
    ''');

    // Create coupons table
    await db.execute('''
      CREATE TABLE $couponTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE,
        discountPercentage REAL NOT NULL,
        expiryDate TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');
  }

  // Generic insert method
  Future<int> insert(String table, Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert(table, row);
  }

  // Generic query method
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    Database db = await database;
    return await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  // Generic update method
  Future<int> update(
    String table,
    Map<String, dynamic> row, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    Database db = await database;
    return await db.update(table, row, where: where, whereArgs: whereArgs);
  }

  // Generic delete method
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    Database db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }
}
