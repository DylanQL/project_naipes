import 'package:flutter/material.dart';
import '../models/card_model.dart';

class CardGrid extends StatelessWidget {
  final List<PlayingCard> deck;
  final bool interactive;
  final Function(PlayingCard)? onCardTap;

  const CardGrid({
    super.key, 
    required this.deck, 
    this.interactive = false,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 6 : 4,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 2/3,
      ),
      itemCount: deck.length,
      itemBuilder: (context, index) {
        final card = deck[index];
        return PlayingCardWidget(
          card: card,
          index: index + 1,
          interactive: interactive,
          onTap: interactive && onCardTap != null 
            ? () => onCardTap!(card) 
            : null,
        );
      },
    );
  }
}

class PlayingCardWidget extends StatelessWidget {
  final PlayingCard card;
  final int index;
  final bool interactive;
  final VoidCallback? onTap;

  const PlayingCardWidget({
    super.key,
    required this.card,
    required this.index,
    this.interactive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Colores específicos para las cartas en modo oscuro
    Color cardColor;
    if (card.suit == 'H' || card.suit == 'D') {
      // Corazones y diamantes - rojo
      cardColor = isDarkMode ? const Color(0xFFFF7070) : Colors.red.shade700;
    } else {
      // Picas y tréboles - negro/blanco
      cardColor = isDarkMode ? const Color(0xFFDDDDDD) : Colors.black87;
    }
    
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;
        
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isDarkMode ? 8.0 : 4.0,
        shadowColor: isDarkMode ? Colors.black87 : Colors.black38,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: interactive 
              ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
              : isDarkMode
                  ? BorderSide(color: const Color(0xFF444444), width: 1.0)
                  : BorderSide.none,
        ),
        child: Container(
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode 
                ? [const Color(0xFF2A2A3A), const Color(0xFF1A1A28)]
                : [Colors.white, Colors.grey.shade100],
            ),
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: isDarkMode ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ] : null,
          ),
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: isSmallScreen ? 50 : 70,
              height: isSmallScreen ? 75 : 105,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF333344).withOpacity(0.7) : null,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$index',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 8 : 10, 
                          color: isDarkMode ? const Color(0xFFBBBBCC) : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    card.value,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 24,
                      fontWeight: FontWeight.bold,
                      color: cardColor,
                      shadows: isDarkMode ? [
                        Shadow(
                          color: Colors.black.withOpacity(0.7),
                          blurRadius: 1,
                          offset: const Offset(0, 1),
                        )
                      ] : null,
                    ),
                  ),
                  Text(
                    Deck.getSuitSymbol(card.suit),
                    style: TextStyle(
                      fontSize: isSmallScreen ? 24 : 32,
                      color: cardColor,
                      shadows: isDarkMode ? [
                        Shadow(
                          color: Colors.black.withOpacity(0.7),
                          blurRadius: 1,
                          offset: const Offset(0, 1),
                        )
                      ] : null,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
