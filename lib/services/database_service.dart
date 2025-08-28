import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/card_model.dart';
import '../models/score_model.dart';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

// Importaciones para plataformas nativas
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Inicializar base de datos para plataformas nativas
Future<void> initDatabaseForNative() async {
  if (!kIsWeb) {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }
}

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  static SharedPreferences? _prefs;
  
  factory DatabaseService() => _instance;
  
  DatabaseService._internal();
  
  Future<dynamic> get database async {
    if (kIsWeb) {
      if (_prefs == null) {
        _prefs = await SharedPreferences.getInstance();
      }
      return _prefs;
    } else {
      if (_database != null) return _database!;
      _database = await _initDatabase();
      return _database!;
    }
  }
  
  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError('Native database is not supported on web');
    }
    
    String dbPath = path.join(await getDatabasesPath(), 'card_memory.db');
    
    return await openDatabase(
      dbPath,
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
    // Convert the deck to JSON
    final List<Map<String, dynamic>> deckMaps = deck.map((card) => card.toMap()).toList();
    final String deckJson = json.encode(deckMaps);
    
    if (kIsWeb) {
      // Web storage implementation using SharedPreferences
      final prefs = await database as SharedPreferences;
      await prefs.setString('deck_order', deckJson);
    } else {
      // Native database implementation
      final db = await database as Database;
      // Delete existing deck orders
      await db.delete('deck');
      
      // Save the new deck order
      await db.insert('deck', {'order_json': deckJson});
    }
  }
  
  Future<List<PlayingCard>> getDeckOrder() async {
    if (kIsWeb) {
      // Web storage implementation
      final prefs = await database as SharedPreferences;
      final String? deckJson = prefs.getString('deck_order');
      
      if (deckJson == null || deckJson.isEmpty) {
        return [];
      }
      
      final List<dynamic> decoded = json.decode(deckJson);
      return decoded.map<PlayingCard>((json) => PlayingCard.fromMap(json)).toList();
    } else {
      // Native database implementation
      final db = await database as Database;
      
      final List<Map<String, dynamic>> maps = await db.query('deck');
      
      if (maps.isEmpty) {
        return [];
      }
      
      final String deckJson = maps.first['order_json'] as String;
      final List<dynamic> decoded = json.decode(deckJson);
      
      return decoded.map<PlayingCard>((json) => PlayingCard.fromMap(json)).toList();
    }
  }
  
  // Scores operations
  Future<void> saveScore(ScoreRecord score) async {
    if (kIsWeb) {
      // Web storage implementation
      final prefs = await database as SharedPreferences;
      final String scoreKey = 'score_${DateTime.now().millisecondsSinceEpoch}';
      await prefs.setString(scoreKey, json.encode(score.toMap()));
      
      // Also update the score index
      List<String> scoreKeys = prefs.getStringList('score_keys') ?? [];
      scoreKeys.add(scoreKey);
      await prefs.setStringList('score_keys', scoreKeys);
    } else {
      // Native database implementation
      final db = await database as Database;
      await db.insert('scores', score.toMap());
    }
  }
  
  Future<List<ScoreRecord>> getTopScores({int limit = 20}) async {
    if (kIsWeb) {
      // Web storage implementation
      final prefs = await database as SharedPreferences;
      List<ScoreRecord> scores = [];
      
      // Get the list of score keys
      List<String> scoreKeys = prefs.getStringList('score_keys') ?? [];
      
      // Collect all scores
      for (String key in scoreKeys) {
        final String? scoreJson = prefs.getString(key);
        if (scoreJson != null) {
          try {
            final map = json.decode(scoreJson) as Map<String, dynamic>;
            scores.add(ScoreRecord.fromMap(map));
          } catch (e) {
            print('Error parsing score: $e');
          }
        }
      }
      
      // Sort by score (descending) and time (ascending)
      scores.sort((a, b) {
        final scoreComparison = b.score.compareTo(a.score);
        if (scoreComparison != 0) return scoreComparison;
        return a.timeInSeconds.compareTo(b.timeInSeconds);
      });
      
      // Return top scores
      return scores.take(limit).toList();
    } else {
      // Native database implementation
      final db = await database as Database;
      
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
}
