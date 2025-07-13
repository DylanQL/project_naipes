import 'dart:math';
import '../models/card_model.dart';
import 'database_service.dart';

class GameService {
  final DatabaseService _dbService = DatabaseService();
  List<PlayingCard> _currentDeck = [];
  
  List<PlayingCard> get currentDeck => _currentDeck;
  
  Future<void> loadCurrentDeck() async {
    _currentDeck = await _dbService.getDeckOrder();
    if (_currentDeck.isEmpty) {
      _currentDeck = Deck.generateDeck();
    }
  }
  
  Future<void> shuffleDeck() async {
    // Generate a standard deck
    _currentDeck = Deck.generateDeck();
    
    // Shuffle the deck
    final random = Random();
    for (var i = _currentDeck.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = _currentDeck[i];
      _currentDeck[i] = _currentDeck[j];
      _currentDeck[j] = temp;
    }
    
    // Save the shuffled deck to database
    await _dbService.saveDeckOrder(_currentDeck);
  }
  
  bool verifyCardOrder(List<PlayingCard> guessedDeck) {
    if (guessedDeck.length != _currentDeck.length) {
      return false;
    }
    
    for (int i = 0; i < _currentDeck.length; i++) {
      if (guessedDeck[i].abbreviation != _currentDeck[i].abbreviation) {
        return false;
      }
    }
    
    return true;
  }
  
  int calculateScore(List<PlayingCard> guessedDeck) {
    int score = 0;
    
    int minLength = min(guessedDeck.length, _currentDeck.length);
    
    for (int i = 0; i < minLength; i++) {
      if (guessedDeck[i].abbreviation == _currentDeck[i].abbreviation) {
        score++;
      }
    }
    
    return score;
  }
}
