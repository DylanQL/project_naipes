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
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suan Cards'),
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
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 80 : 20, 
                vertical: isDesktop ? 40 : 20
              ),
              // Use LayoutBuilder to adapt to screen size
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Desktop layout - prioritized
                  if (isDesktop) {
                    return _buildDesktopLayout(context);
                  } 
                  // Check if the screen is in landscape mode (for mobile/tablet)
                  else if (MediaQuery.of(context).orientation == Orientation.landscape) {
                    return _buildLandscapeLayout(context);
                  } 
                  // Portrait layout (for mobile)
                  else {
                    return _buildPortraitLayout(context);
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Nuevo diseño optimizado para pantallas de escritorio
  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna izquierda: Logo y descripción
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/logo_suan_cars.png',
                  width: 120,
                  height: 120,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Suan Cards',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Text(
                  'Train your memory by memorizing a deck of cards',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[300]
                        : Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Text(
                  'Challenge yourself to memorize all 52 cards!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Espacio entre columnas
        const SizedBox(width: 60),
        
        // Columna derecha: Menú de opciones
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Memory Training Tools',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Use these tools to practice memorizing card sequences',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Grid de botones para escritorio
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 1.5,
                  children: [
                    _buildDesktopMenuCard(
                      title: 'Shuffle Deck',
                      description: 'Generate a new random card order',
                      icon: Icons.shuffle,
                      onPressed: isLoading ? null : _shuffleDeck,
                      isPrimary: true,
                    ),
                    _buildDesktopMenuCard(
                      title: 'View Current Deck',
                      description: 'See the current order of all 52 cards',
                      icon: Icons.visibility,
                      onPressed: _viewCurrentDeck,
                    ),
                    _buildDesktopMenuCard(
                      title: 'Test Your Memory',
                      description: 'Challenge yourself to recall the deck order',
                      icon: Icons.psychology,
                      onPressed: _startTestMode,
                    ),
                    _buildDesktopMenuCard(
                      title: 'View Scoreboard',
                      description: 'Check your progress and past scores',
                      icon: Icons.leaderboard,
                      onPressed: _viewScoreboard,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Layout para dispositivos móviles en modo landscape
  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left side: Logo and title
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/logo_suan_cars.png',
                  width: 60,
                  height: 60,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Suan Cards',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Train your memory by memorizing a deck of cards',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[300]
                      : Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Challenge yourself to memorize all 52 cards!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        // Right side: Menu buttons
        Expanded(
          flex: 3,
          child: Card(
            elevation: 6,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMenuButton(
                    label: 'Shuffle Deck',
                    icon: Icons.shuffle,
                    onPressed: isLoading ? null : _shuffleDeck,
                    isPrimary: true,
                  ),
                  const SizedBox(height: 12),
                  _buildMenuButton(
                    label: 'View Current Deck',
                    icon: Icons.visibility,
                    onPressed: _viewCurrentDeck,
                  ),
                  const SizedBox(height: 12),
                  _buildMenuButton(
                    label: 'Test Your Memory',
                    icon: Icons.psychology,
                    onPressed: _startTestMode,
                  ),
                  const SizedBox(height: 12),
                  _buildMenuButton(
                    label: 'View Scoreboard',
                    icon: Icons.leaderboard,
                    onPressed: _viewScoreboard,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Layout para dispositivos móviles en modo portrait
  Widget _buildPortraitLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Image.asset(
            'assets/images/logo_suan_cars.png',
            width: 80,
            height: 80,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Suan Cards',
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
    );
  }

  // Botón de menú para desktop con estilo de tarjeta
  Widget _buildDesktopMenuCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback? onPressed,
    bool isPrimary = false,
  }) {
    return Card(
      elevation: isPrimary ? 8 : 4,
      shadowColor: isPrimary
          ? Theme.of(context).colorScheme.primary.withOpacity(0.4)
          : Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isPrimary
            ? BorderSide.none
            : BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                width: 1,
              ),
      ),
      color: isPrimary
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).cardTheme.color,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: isPrimary
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isPrimary
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: isPrimary
                      ? Colors.white.withOpacity(0.8)
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
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
