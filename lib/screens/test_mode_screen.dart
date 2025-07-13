import 'dart:async';
import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../services/game_service.dart';
import '../services/database_service.dart';
import '../models/score_model.dart';
import '../widgets/card_grid.dart';

class TestModeScreen extends StatefulWidget {
  final GameService gameService;
  
  const TestModeScreen({super.key, required this.gameService});

  @override
  State<TestModeScreen> createState() => _TestModeScreenState();
}

class _TestModeScreenState extends State<TestModeScreen> {
  List<PlayingCard> deck = Deck.generateDeck();
  List<PlayingCard> guessedDeck = [];
  bool isLoading = true;
  bool isTestInProgress = false;
  bool isTestCompleted = false;
  int score = 0;
  
  // Timer variables
  Timer? _timer;
  int _secondsElapsed = 0;
  
  final TextEditingController nameController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadDeck();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    nameController.dispose();
    super.dispose();
  }
  
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }
  
  void _stopTimer() {
    _timer?.cancel();
  }
  
  String get formattedTime {
    final minutes = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _loadDeck() async {
    setState(() {
      isLoading = true;
    });
    
    await widget.gameService.loadCurrentDeck();
    
    setState(() {
      isLoading = false;
    });
  }
  
  void _startTest() {
    setState(() {
      guessedDeck = [];
      isTestInProgress = true;
      isTestCompleted = false;
      _secondsElapsed = 0;
    });
    _startTimer();
  }
  
  void _addCardToGuess(PlayingCard card) {
    if (guessedDeck.contains(card)) {
      return;
    }
    
    setState(() {
      guessedDeck.add(card);
    });
    
    // Check if all cards have been added
    if (guessedDeck.length == 52) {
      _completeTest();
    }
  }
  
  void _removeCardFromGuess(int index) {
    setState(() {
      guessedDeck.removeAt(index);
    });
  }
  
  void _completeTest() {
    _stopTimer();
    
    // Calculate score
    final score = widget.gameService.calculateScore(guessedDeck);
    
    setState(() {
      this.score = score;
      isTestInProgress = false;
      isTestCompleted = true;
    });
  }
  
  Future<void> _saveScore() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa tu nombre')),
      );
      return;
    }
    
    final scoreRecord = ScoreRecord(
      playerName: nameController.text,
      score: score,
      timeInSeconds: _secondsElapsed,
      date: DateTime.now(),
    );
    
    await DatabaseService().saveScore(scoreRecord);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Puntuación guardada!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Mode'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          if (isTestInProgress)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                formattedTime,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }
  
  Widget _buildContent() {
    if (!isTestInProgress && !isTestCompleted) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ready to test your memory?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Try to recall all 52 cards in the correct order',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _startTest,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Start Test', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      );
    } else if (isTestInProgress) {
      return Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF202020)
                : Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Text(
                      'Selected Cards: ${guessedDeck.length}/52',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: guessedDeck.isEmpty
                      ? Center(
                          child: Text(
                            'Select cards in the correct order',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: guessedDeck.length,
                          itemBuilder: (context, index) {
                            final card = guessedDeck[index];
                            return GestureDetector(
                              onTap: () => _removeCardFromGuess(index),
                              child: Tooltip(
                                message: 'Tap to remove',
                                child: Container(
                                  width: 50,
                                  margin: const EdgeInsets.all(4.0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness == Brightness.dark
                                      ? const Color(0xFF2C2C2C)
                                      : Colors.white,
                                    border: Border.all(
                                      color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.black54
                                          : Colors.black12,
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [                                  Text(
                                    card.value,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: card.suit == 'H' || card.suit == 'D'
                                          ? (Theme.of(context).brightness == Brightness.dark 
                                              ? Colors.red.shade300 
                                              : Colors.red.shade700)
                                          : (Theme.of(context).brightness == Brightness.dark 
                                              ? Colors.white 
                                              : Colors.black87),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),                                  Text(
                                    Deck.getSuitSymbol(card.suit),
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: card.suit == 'H' || card.suit == 'D'
                                          ? (Theme.of(context).brightness == Brightness.dark 
                                              ? Colors.red.shade300 
                                              : Colors.red.shade700)
                                          : (Theme.of(context).brightness == Brightness.dark 
                                              ? Colors.white 
                                              : Colors.black87),
                                    ),
                                  ),
                                      Container(
                                        width: double.infinity,
                                        color: Theme.of(context).brightness == Brightness.dark 
                                          ? Colors.grey.shade800 
                                          : Colors.grey.shade100,
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            fontSize: 10, 
                                            color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.grey.shade400
                                              : Colors.grey,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: CardGrid(
              deck: deck,
              interactive: true,
              onCardTap: _addCardToGuess,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Selected: ${guessedDeck.length}/52',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: guessedDeck.length == 52 ? _completeTest : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Complete Test'),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Test completed
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Test Complete!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Your score: $score/52',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                'Time: $formattedTime',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),
              const Text('Enter your name to save your score:'),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Your name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveScore,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Save Score', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      );
    }
  }
}
