import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import '../models/card_model.dart';
import '../models/score_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  
  factory DatabaseService() => _instance;
  
  DatabaseService._internal();
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'card_memory.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Create the deck table
    await db.execute('''
      CREATE TABLE deck(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_json TEXT NOT NULL
      )
    ''');
    
    // Create the scores table
    await db.execute('''
      CREATE TABLE scores(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        playerName TEXT NOT NULL,
        score INTEGER NOT NULL,
        timeInSeconds INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }
  
  // Deck operations
  Future<void> saveDeckOrder(List<PlayingCard> deck) async {
    final db = await database;
    
    // Convert the deck to JSON
    final List<Map<String, dynamic>> deckMaps = deck.map((card) => card.toMap()).toList();
    final String deckJson = json.encode(deckMaps);
    
    // Delete existing deck orders
    await db.delete('deck');
    
    // Save the new deck order
    await db.insert('deck', {'order_json': deckJson});
  }
  
  Future<List<PlayingCard>> getDeckOrder() async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query('deck');
    
    if (maps.isEmpty) {
      return [];
    }
    
    final String deckJson = maps.first['order_json'] as String;
    final List<dynamic> decoded = json.decode(deckJson);
    
    return decoded.map<PlayingCard>((json) => PlayingCard.fromMap(json)).toList();
  }
  
  // Scores operations
  Future<void> saveScore(ScoreRecord score) async {
    final db = await database;
    await db.insert('scores', score.toMap());
  }
  
  Future<List<ScoreRecord>> getTopScores({int limit = 20}) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'scores',
      orderBy: 'score DESC, timeInSeconds ASC',
      limit: limit,
    );
    
    return List.generate(maps.length, (i) {
      return ScoreRecord.fromMap(maps[i]);
    });
  }
}
