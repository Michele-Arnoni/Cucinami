import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('recipe.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE UNIT (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE INGREDIENT (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity REAL NOT NULL,
        unitId INTEGER NOT NULL,
        FOREIGN KEY (unitId) REFERENCES UNIT(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE RECIPT (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE RECIPT_INGREDIENT (
        reciptId INTEGER NOT NULL,
        ingredientId INTEGER NOT NULL,
        PRIMARY KEY (reciptId, ingredientId),
        FOREIGN KEY (reciptId) REFERENCES RECIPT(id),
        FOREIGN KEY (ingredientId) REFERENCES INGREDIENT(id)
      )
    ''');
  }

  // Inserisci unità
  Future<int> insertUnit(String name) async {
    final db = await instance.database;
    return await db.insert('UNIT', {'name': name});
  }

  // Inserisci ingrediente
  Future<int> insertIngredient(String name, double quantity, int unitId) async {
    final db = await instance.database;
    return await db.insert('INGREDIENT', {
      'name': name,
      'quantity': quantity,
      'unitId': unitId,
    });
  }

  // Inserisci ricetta
  Future<int> insertRecipt(String name) async {
    final db = await instance.database;
    return await db.insert('RECIPT', {'name': name});
  }

  // Aggiorna ricetta
  Future<void> updateRecipt(int reciptId, String nomeRicetta) async {
    final db = await instance.database;
    await db.update(
      'RECIPT',
      {'name': nomeRicetta},
      where: 'id = ?',
      whereArgs: [reciptId],
    );
  }

  // Associa ingrediente a ricetta
  Future<void> addIngredientToRecipt(int reciptId, int ingredientId) async {
    final db = await instance.database;
    await db.insert('RECIPT_INGREDIENT', {
      'reciptId': reciptId,
      'ingredientId': ingredientId,
    });
  }

  // Recupera tutte le ricette
  Future<List<Map<String, dynamic>>> getAllRecipts() async {
    final db = await instance.database;
    return await db.query('RECIPT');
  }

  // Recupera ricetta per id
  Future<Map<String, dynamic>?> getReciptById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'RECIPT',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Recupera ingredienti di una ricetta per id
  Future<List<Map<String, dynamic>>> getIngredientsForRecipt(int reciptId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
      SELECT i.id, i.name, i.quantity, u.name AS unitName
      FROM RECIPT_INGREDIENT ri
      JOIN INGREDIENT i ON ri.ingredientId = i.id
      JOIN UNIT u ON i.unitId = u.id
      WHERE ri.reciptId = ?
    ''', [reciptId]);

    return result;
  }

  // Elimina associazioni ingredienti-ricetta
  Future<void> deleteReciptIngredients(int reciptId) async {
    final db = await instance.database;
    await db.delete(
      'RECIPT_INGREDIENT',
      where: 'reciptId = ?',
      whereArgs: [reciptId],
    );
  }

  // Svuota tutti gli ingredienti da una ricetta
  Future<void> clearIngredientsFromRecipt(int reciptId) async {
    final db = await instance.database;
    await db.delete(
      'RECIPT_INGREDIENT',
      where: 'reciptId = ?',
      whereArgs: [reciptId],
    );
  }

  // Elimina ricetta
  Future<void> deleteRecipt(int reciptId) async {
    final db = await instance.database;
    await deleteReciptIngredients(reciptId); // prima le associazioni
    await db.delete(
      'RECIPT',
      where: 'id = ?',
      whereArgs: [reciptId],
    );
  }

  // Recupera ingredienti di una ricetta per nome
  Future<List<Map<String, dynamic>>> getIngredientsByRecipt(String nomeRicetta) async {
    final db = await instance.database;

    final result = await db.rawQuery('''
      SELECT i.name, i.quantity, u.name AS unitName
      FROM RECIPT r
      JOIN RECIPT_INGREDIENT ri ON r.id = ri.reciptId
      JOIN INGREDIENT i ON ri.ingredientId = i.id
      JOIN UNIT u ON i.unitId = u.id
      WHERE r.name = ?
    ''', [nomeRicetta]);

    return result;
  }
}
