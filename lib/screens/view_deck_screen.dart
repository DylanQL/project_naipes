import 'package:flutter/material.dart';
import '../services/game_service.dart';
import '../widgets/card_grid.dart';
import '../models/card_model.dart';

class ViewDeckScreen extends StatefulWidget {
  final GameService gameService;
  
  const ViewDeckScreen({super.key, required this.gameService});

  @override
  State<ViewDeckScreen> createState() => _ViewDeckScreenState();
}

class _ViewDeckScreenState extends State<ViewDeckScreen> {
  List<PlayingCard> deck = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeck();
  }

  Future<void> _loadDeck() async {
    setState(() {
      isLoading = true;
    });
    
    await widget.gameService.loadCurrentDeck();
    
    setState(() {
      deck = widget.gameService.currentDeck;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Deck Order'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: EdgeInsets.all(isDesktop ? 24.0 : 8.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDesktop) ...[
                    // Encabezado y descripción para escritorio
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.view_column_rounded,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Deck Arrangement',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Take your time to memorize the order of all 52 cards',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Contador de cartas
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.style,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${deck.length} Cards',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  // Grid de cartas con adaptación responsiva
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context).colorScheme.surface,
                            Theme.of(context).colorScheme.surface.withOpacity(0.9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(isDesktop ? 16 : 8),
                        boxShadow: isDesktop 
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                )
                              ] 
                            : null,
                      ),
                      padding: EdgeInsets.all(isDesktop ? 20.0 : 8.0),
                      child: CardGrid(
                        deck: deck,
                        forDesktop: isDesktop,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
