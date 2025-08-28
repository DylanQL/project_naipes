import 'package:flutter/material.dart';
import '../models/card_model.dart';

class CardGrid extends StatelessWidget {
  final List<PlayingCard> deck;
  final bool interactive;
  final bool forDesktop;
  final Function(PlayingCard)? onCardTap;
  final List<PlayingCard>? selectedCards;
  final bool hideSelectedCards;

  const CardGrid({
    super.key, 
    required this.deck, 
    this.interactive = false,
    this.forDesktop = false,
    this.onCardTap,
    this.selectedCards,
    this.hideSelectedCards = false,
  });

  @override
  Widget build(BuildContext context) {
    // Detect orientation and screen size
    final orientation = MediaQuery.of(context).orientation;
    final screenSize = MediaQuery.of(context).size;
    
    // Adjust grid based on orientation, screen size and desktop mode
    int crossAxisCount;
    double aspectRatio;
    
    if (forDesktop) {
      // Desktop optimized layout
      if (screenSize.width > 1600) {
        crossAxisCount = 13; // Full deck width for very large screens
        aspectRatio = 2/3;
      } else if (screenSize.width > 1200) {
        crossAxisCount = 10; // For large desktop screens
        aspectRatio = 2/3;
      } else {
        crossAxisCount = 8; // For smaller desktop screens
        aspectRatio = 2/3;
      }
    } else if (orientation == Orientation.landscape) {
      // In landscape mode for mobile/tablet, show more cards horizontally
      if (screenSize.width > 900) { // Large tablets
        crossAxisCount = 8;
      } else if (screenSize.width > 600) { // Small tablets and large phones
        crossAxisCount = 6;
      } else { // Most phones in landscape
        crossAxisCount = 5;
      }
      // Slightly adjust aspect ratio for landscape
      aspectRatio = 2/3.2;
    } else {
      // Portrait mode for mobile/tablet
      if (screenSize.width > 600) { // Tablets in portrait
        crossAxisCount = 6;
      } else if (screenSize.width > 400) { // Large phones in portrait
        crossAxisCount = 4;
      } else { // Small phones in portrait
        crossAxisCount = 3;
      }
      // Standard aspect ratio for portrait
      aspectRatio = 2/3;
    }
    
    // Filtrar las cartas seleccionadas si hideSelectedCards es true
    List<PlayingCard> visibleDeck = deck;
    if (hideSelectedCards && selectedCards != null) {
      visibleDeck = deck.where((card) => !selectedCards!.contains(card)).toList();
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: visibleDeck.length,
      itemBuilder: (context, index) {
        final card = visibleDeck[index];
        
        return PlayingCardWidget(
          card: card,
          index: index,
          onTap: onCardTap != null ? () => onCardTap!(card) : null,
          interactive: interactive,
          forDesktop: forDesktop,
        );
      },
    );
  }
}

class PlayingCardWidget extends StatelessWidget {
  final PlayingCard card;
  final int index;
  final bool interactive;
  final bool forDesktop;
  final VoidCallback? onTap;

  const PlayingCardWidget({
    super.key,
    required this.card,
    required this.index,
    this.interactive = false,
    this.forDesktop = false,
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
        elevation: isDarkMode ? 8.0 : (forDesktop ? 6.0 : 4.0),
        shadowColor: isDarkMode ? Colors.black87 : Colors.black38,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(forDesktop ? 16.0 : 12.0),
          side: interactive 
              ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
              : isDarkMode
                  ? BorderSide(color: const Color(0xFF444444), width: 1.0)
                  : BorderSide.none,
        ),
        child: Container(
          padding: EdgeInsets.all(forDesktop ? 8.0 : 6.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode 
                ? [const Color(0xFF2A2A3A), const Color(0xFF1A1A28)]
                : [Colors.white, Colors.grey.shade100],
            ),
            borderRadius: BorderRadius.circular(forDesktop ? 16.0 : 12.0),
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
              width: forDesktop ? 90 : (isSmallScreen ? 50 : 70),
              height: forDesktop ? 135 : (isSmallScreen ? 75 : 105),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: EdgeInsets.all(forDesktop ? 4.0 : 2.0),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF333344).withOpacity(0.7) : null,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$index',
                        style: TextStyle(
                          fontSize: forDesktop ? 12 : (isSmallScreen ? 8 : 10), 
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
                      fontSize: forDesktop ? 32 : (isSmallScreen ? 18 : 24),
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
                      fontSize: forDesktop ? 40 : (isSmallScreen ? 24 : 32),
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
