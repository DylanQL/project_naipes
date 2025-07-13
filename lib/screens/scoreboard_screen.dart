import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/score_model.dart';

class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  bool isLoading = true;
  List<ScoreRecord> scores = [];
  
  @override
  void initState() {
    super.initState();
    _loadScores();
  }
  
  Future<void> _loadScores() async {
    setState(() {
      isLoading = true;
    });
    
    final databaseService = DatabaseService();
    final topScores = await databaseService.getTopScores(limit: 20);
    
    setState(() {
      scores = topScores;
      isLoading = false;
    });
  }
  
  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scoreboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : scores.isEmpty
              ? const Center(
                  child: Text(
                    'No scores yet! Complete a test to see your score here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Top 20 Scores',
                        style: TextStyle(
                          fontSize: 22, 
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: scores.length,
                          itemBuilder: (context, index) {
                            final score = scores[index];
                            return Card(
                              elevation: 2.0,
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  child: Text('${index + 1}'),
                                ),
                                title: Text(
                                  score.playerName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  'Date: ${_formatDate(score.date)}',
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Score: ${score.score}/52',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text('Time: ${_formatTime(score.timeInSeconds)}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadScores,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
