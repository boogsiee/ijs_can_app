import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._init();
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ijsCan.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: (db) async {
        // Automatically seed mock users if table is empty
        final userCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users'));
        if (userCount == 0 || userCount == null) {
          await db.insert('users', {'username': 'admin', 'password': 'password123', 'role': 'admin'});
          await db.insert('users', {'username': 'canteen_vendor', 'password': 'vendorpassword', 'role': 'vendor'});
          await db.insert('users', {'username': 'student_juan', 'password': 'password', 'role': 'student'});
          await db.insert('users', {'username': 'parent_delacruz', 'password': 'password', 'role': 'parent'});
          await db.insert('parent_student_links', {'parent_id': 4, 'student_id': 3});
        }

        // Automatically seed products if table is empty
        final productCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM products'));
        if (productCount == 0 || productCount == null) {
          await db.insert('products', {'name': 'Pancit Canton Special', 'category': 'Food', 'price': 35.00, 'stock': 50, 'is_available': 1});
          await db.insert('products', {'name': 'School ID Lanyard', 'category': 'Merchandise', 'price': 75.00, 'stock': 20, 'is_available': 1});
        }
      },
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE parent_student_links (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        parent_id INTEGER,
        student_id INTEGER,
        FOREIGN KEY (parent_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (student_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL,
        is_available INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        user_id INTEGER,
        total_price REAL NOT NULL,
        order_type TEXT NOT NULL,
        payment_method TEXT NOT NULL DEFAULT 'Cash',
        status TEXT NOT NULL DEFAULT 'Pending',
        order_date TEXT NOT NULL,
        target_serving_date TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT,
        product_id INTEGER,
        quantity INTEGER NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');
  }

  Future<String?> authenticateUser(String username, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      return result.first['role'] as String;
    }
    return null;
  }

  Future<int> updateProductAvailability(int productId, bool isAvailable) async {
    final db = await instance.database;
    return await db.update(
      'products',
      {'is_available': is_available ? 1 : 0},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  Future<List<Map<String, dynamic>>> getOrdersForUser(int userId) async {
    final db = await instance.database;
    return await db.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'order_date DESC',
    );
  }
}