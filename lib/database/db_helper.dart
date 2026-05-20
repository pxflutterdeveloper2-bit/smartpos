import 'package:path_provider/path_provider.dart';
import 'package:smartpos/models/product.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'smart_pos.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    Create table products(
    id integer primary key autoincrement,
    name text not null,
    price real not null,
    stock integer not null default 0,
    created_at text not null
    )
    ''');
    await db.execute('''
      CREATE TABLE orders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_number TEXT NOT NULL,
        total_amount REAL NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        customer_name TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY(order_id) REFERENCES orders(id) ON DELETE CASCADE,
        FOREIGN KEY(product_id) REFERENCES products(id)
      )
    ''');
  }

  Future<List<Product>> getProducts({String query = ''}) async {
    final db = await database;
    final maps = await db.query(
      'products',
      where: query.trim().isEmpty ? null : 'LOWER(name) LIKE ?',
      whereArgs: query.trim().isEmpty ? null : ['%${query.toLowerCase()}%'],
      orderBy: 'name ASC',
    );
    return maps.map(Product.fromMap).toList();
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return db.insert(
      'products',
      product.copyWith(createdAt: DateTime.now().toIso8601String()).toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return db.update(
      'products',
      product.toMap(),
      where: 'id=?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return db.delete('products', where: 'id=?', whereArgs: [id]);
  }

  Future<Map<String, num>> getDashboardStats() async {
    final db = await database;
    final sales =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT ROUND(SUM(total_amount)) FROM orders'),
        ) ??
        0;
    final orders =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM orders'),
        ) ??
        0;
    final products =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM products'),
        ) ??
        0;
    return {'sales': sales, 'orders': orders, 'products': products};
  }
}
