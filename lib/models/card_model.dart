class PlayingCard {
  final String suit;
  final String value;
  
  const PlayingCard({required this.suit, required this.value});
  
  String get abbreviation => '$value-$suit';
  
  @override
  String toString() => abbreviation;
  
  factory PlayingCard.fromAbbreviation(String abbr) {
    final parts = abbr.split('-');
    return PlayingCard(value: parts[0], suit: parts[1]);
  }
  
  Map<String, dynamic> toMap() {
    return {
      'suit': suit,
      'value': value,
    };
  }
  
  factory PlayingCard.fromMap(Map<String, dynamic> map) {
    return PlayingCard(
      suit: map['suit'],
      value: map['value'],
    );
  }
}

class Deck {
  static const suits = ['C', 'D', 'H', 'S']; // Clubs, Diamonds, Hearts, Spades
  static const values = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'];

  static List<PlayingCard> generateDeck() {
    List<PlayingCard> deck = [];
    
    for (var suit in suits) {
      for (var value in values) {
        deck.add(PlayingCard(suit: suit, value: value));
      }
    }
    
    return deck;
  }
  
  static String getSuitFullName(String suit) {
    switch (suit) {
      case 'C': return 'Clubs';
      case 'D': return 'Diamonds';
      case 'H': return 'Hearts';
      case 'S': return 'Spades';
      default: return 'Unknown';
    }
  }
  
  static String getValueFullName(String value) {
    switch (value) {
      case 'A': return 'Ace';
      case 'J': return 'Jack';
      case 'Q': return 'Queen';
      case 'K': return 'King';
      default: return value;
    }
  }
  
  static String getSuitSymbol(String suit) {
    switch (suit) {
      case 'C': return '♣️';
      case 'D': return '♦️';
      case 'H': return '♥️';
      case 'S': return '♠️';
      default: return suit;
    }
  }
  
  static String getCardDescription(PlayingCard card) {
    return '${getValueFullName(card.value)} of ${getSuitFullName(card.suit)}';
  }
}
