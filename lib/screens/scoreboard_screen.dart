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
    final screenSize = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isDesktop = screenSize.width > 1024;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scoreboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : scores.isEmpty
              ? Center(
                  child: Container(
                    padding: EdgeInsets.all(isDesktop ? 40 : 24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.assignment_late_outlined,
                          size: isDesktop ? 80 : 60,
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No scores yet!',
                          style: TextStyle(
                            fontSize: isDesktop ? 28 : 22,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Complete a test to see your score here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isDesktop ? 18 : 16,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Back to Home'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 32 : 24, 
                              vertical: isDesktop ? 16 : 12
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : isDesktop
                  ? _buildDesktopScoreboard()
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

  // Layout optimizado para pantallas de escritorio
  Widget _buildDesktopScoreboard() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel lateral con información y estadísticas
          Container(
            width: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.emoji_events_rounded,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Top Scores',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Memory Training Challenge',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Estadísticas
                const Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Top score
                _buildStatisticItem(
                  icon: Icons.stars, 
                  title: 'Highest Score', 
                  value: '${scores.isNotEmpty ? scores[0].score : 0}/52',
                  iconColor: Colors.amber,
                ),
                
                const SizedBox(height: 16),
                
                // Fastest time with score > 40
                _buildStatisticItem(
                  icon: Icons.timer, 
                  title: 'Fastest Time (score > 40)', 
                  value: _getFastestTimeText(),
                  iconColor: Colors.blue,
                ),
                
                const SizedBox(height: 16),
                
                // Total attempts
                _buildStatisticItem(
                  icon: Icons.repeat, 
                  title: 'Total Attempts', 
                  value: '${scores.length}',
                  iconColor: Colors.green,
                ),
                
                const Spacer(),
                
                // Botón de actualizar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loadScores,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Scores'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 32),
          
          // Tabla de puntajes
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scoreboard',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Top 20 performances',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Encabezados de la tabla
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: Text(
                            'Rank',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Player',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Score',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Time',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Date',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Lista de puntajes
                  Expanded(
                    child: ListView.builder(
                      itemCount: scores.length,
                      itemBuilder: (context, index) {
                        final score = scores[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: index % 2 == 0 
                              ? Theme.of(context).colorScheme.surface 
                              : Theme.of(context).colorScheme.primary.withOpacity(0.05),
                            border: Border(
                              bottom: BorderSide(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          child: Row(
                            children: [
                              // Rank
                              SizedBox(
                                width: 40,
                                child: _buildRankWidget(index + 1),
                              ),
                              // Player
                              Expanded(
                                flex: 3,
                                child: Text(
                                  score.playerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              // Score
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${score.score}/52',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _getScoreColor(score.score),
                                  ),
                                ),
                              ),
                              // Time
                              Expanded(
                                flex: 2,
                                child: Text(
                                  _formatTime(score.timeInSeconds),
                                ),
                              ),
                              // Date
                              Expanded(
                                flex: 2,
                                child: Text(
                                  _formatDate(score.date),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Widget para mostrar un elemento de estadística
  Widget _buildStatisticItem({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Widget para mostrar el ranking con estilo
  Widget _buildRankWidget(int rank) {
    Color backgroundColor;
    Color textColor = Colors.white;
    
    if (rank == 1) {
      backgroundColor = Colors.amber;
    } else if (rank == 2) {
      backgroundColor = Colors.grey.shade400;
    } else if (rank == 3) {
      backgroundColor = Colors.brown.shade300;
    } else {
      backgroundColor = Theme.of(context).colorScheme.primary.withOpacity(0.1);
      textColor = Theme.of(context).colorScheme.onSurface;
    }
    
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$rank',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
          fontSize: 14,
        ),
      ),
    );
  }
  
  // Obtener el texto para el tiempo más rápido
  String _getFastestTimeText() {
    // Filtrar scores mayores a 40
    final highScores = scores.where((s) => s.score > 40).toList();
    if (highScores.isEmpty) {
      return 'N/A';
    }
    
    // Ordenar por tiempo
    highScores.sort((a, b) => a.timeInSeconds.compareTo(b.timeInSeconds));
    
    return _formatTime(highScores.first.timeInSeconds);
  }
  
  // Obtener un color según la puntuación
  Color _getScoreColor(int score) {
    if (score >= 45) {
      return Colors.green;
    } else if (score >= 35) {
      return Colors.blue;
    } else if (score >= 25) {
      return Colors.orange;
    } else {
      return Theme.of(context).colorScheme.onSurface;
    }
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
