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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Deck Order'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : CardGrid(deck: deck),
      ),
    );
  }
}
