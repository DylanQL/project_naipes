import 'package:flutter/material.dart';
import '../services/game_service.dart';
import 'view_deck_screen.dart';
import 'test_mode_screen.dart';
import 'scoreboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GameService gameService = GameService();
  bool isLoading = false;

  Future<void> _shuffleDeck() async {
    setState(() {
      isLoading = true;
    });

    await gameService.shuffleDeck();

    setState(() {
      isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deck shuffled successfully!')),
      );
    }
  }

  void _viewCurrentDeck() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewDeckScreen(gameService: gameService),
      ),
    );
  }

  void _startTestMode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestModeScreen(gameService: gameService),
      ),
    );
  }

  void _viewScoreboard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScoreboardScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Memory Trainer'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.style,
                size: 100,
                color: Colors.black54,
              ),
              const SizedBox(height: 24),
              const Text(
                'Card Memory Trainer',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Train your memory by memorizing a deck of cards',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 48),
              _buildMenuButton(
                label: 'Shuffle Deck',
                icon: Icons.shuffle,
                onPressed: isLoading ? null : _shuffleDeck,
                isPrimary: true,
              ),
              const SizedBox(height: 16),
              _buildMenuButton(
                label: 'View Current Deck',
                icon: Icons.visibility,
                onPressed: _viewCurrentDeck,
              ),
              const SizedBox(height: 16),
              _buildMenuButton(
                label: 'Test Your Memory',
                icon: Icons.psychology,
                onPressed: _startTestMode,
              ),
              const SizedBox(height: 16),
              _buildMenuButton(
                label: 'View Scoreboard',
                icon: Icons.leaderboard,
                onPressed: _viewScoreboard,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    bool isPrimary = false,
  }) {
    return SizedBox(
      width: 250,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          foregroundColor: isPrimary
              ? Colors.white
              : Theme.of(context).colorScheme.onSurface,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    width: 1,
                  ),
          ),
        ),
        icon: isLoading && isPrimary
            ? Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(2.0),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
