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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
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
    Color cardColor = card.suit == 'H' || card.suit == 'D' 
        ? Colors.red 
        : Colors.black;
        
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: interactive 
              ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
              : BorderSide.none,
        ),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey.shade200],
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('$index. ', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
              const Spacer(),
              Text(
                card.value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: cardColor,
                ),
              ),
              Text(
                Deck.getSuitSymbol(card.suit),
                style: TextStyle(
                  fontSize: 32,
                  color: cardColor,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
