import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_service.dart';
import 'view_deck_screen.dart';
import 'test_mode_screen.dart';
import 'scoreboard_screen.dart';
import '../main.dart';

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
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              Theme.of(context).colorScheme.tertiary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.style,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Card Memory Trainer',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Train your memory by memorizing a deck of cards',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[300]
                          : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Card(
                    elevation: 6,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
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
                  const SizedBox(height: 24),
                  Text(
                    'Challenge yourself to memorize all 52 cards!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
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
      width: 280,
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
          elevation: isPrimary ? 4 : 1,
          shadowColor: isPrimary 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.4)
              : Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
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
            : Icon(
                icon,
                size: 24,
                color: isPrimary 
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
              ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
