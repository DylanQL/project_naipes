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
    final orientation = MediaQuery.of(context).orientation;
    
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
                  padding: EdgeInsets.all(orientation == Orientation.landscape ? 12.0 : 16.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.emoji_events_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Top 20 Scores',
                              style: TextStyle(
                                fontSize: 22, 
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: orientation == Orientation.landscape
                            ? _buildLandscapeScoreList()
                            : _buildPortraitScoreList(),
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
  
  // Optimized grid view for landscape mode
  Widget _buildLandscapeScoreList() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.5,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
      ),
      itemCount: scores.length,
      itemBuilder: (context, index) {
        final score = scores[index];
        final bool isTopThree = index < 3;
        final List<Color> medalColors = [
          Colors.amber.shade700,  // Gold
          Colors.grey.shade400,   // Silver
          Colors.brown.shade300,  // Bronze
        ];
        
        return Card(
          elevation: isTopThree ? 4.0 : 2.0,
          shadowColor: isTopThree ? Colors.black38 : Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: isTopThree 
              ? BorderSide(color: medalColors[index], width: 1.5) 
              : BorderSide.none,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Rank/Medal
                CircleAvatar(
                  backgroundColor: isTopThree 
                    ? medalColors[index] 
                    : Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  radius: isTopThree ? 22 : 18,
                  child: isTopThree 
                    ? Icon(
                        Icons.emoji_events_rounded,
                        size: isTopThree ? 24 : 20,
                      )
                    : Text('${index + 1}'),
                ),
                const SizedBox(width: 12),
                
                // Player info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        score.playerName,
                        style: TextStyle(
                          fontWeight: isTopThree ? FontWeight.bold : FontWeight.w500,
                          fontSize: isTopThree ? 16 : 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(score.date),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Score info
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${score.score}/52',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: score.score > 40 
                            ? Colors.green.shade700 
                            : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(score.timeInSeconds),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Original list view for portrait mode
  Widget _buildPortraitScoreList() {
    return ListView.builder(
      itemCount: scores.length,
      itemBuilder: (context, index) {
        final score = scores[index];
        final bool isTopThree = index < 3;
        final List<Color> medalColors = [
          Colors.amber.shade700,  // Gold
          Colors.grey.shade400,   // Silver
          Colors.brown.shade300,  // Bronze
        ];
        
        return Card(
          elevation: isTopThree ? 4.0 : 2.0,
          shadowColor: isTopThree ? Colors.black38 : Colors.black12,
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: isTopThree 
              ? BorderSide(color: medalColors[index], width: 1.5) 
              : BorderSide.none,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 8.0, 
              horizontal: 16.0,
            ),
            leading: CircleAvatar(
              backgroundColor: isTopThree 
                ? medalColors[index] 
                : Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              radius: isTopThree ? 22 : 18,
              child: isTopThree 
                ? Icon(
                    Icons.emoji_events_rounded,
                    size: isTopThree ? 24 : 20,
                  )
                : Text('${index + 1}'),
            ),
            title: Text(
              score.playerName,
              style: TextStyle(
                fontWeight: isTopThree 
                  ? FontWeight.bold 
                  : FontWeight.w500,
                fontSize: isTopThree ? 16 : 15,
              ),
            ),
            subtitle: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(score.date),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${score.score}/52',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: score.score > 40 
                        ? Colors.green.shade700 
                        : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        size: 12,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(score.timeInSeconds),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
