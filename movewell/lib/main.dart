import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(MovementReminderApp());
}

class MovementReminderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movement Reminder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Timer? _reminderTimer;
  Timer? _inactivityTimer;
  DateTime _lastActivityTime = DateTime.now();
  int _reminderInterval = 30; // minutes
  int _completedExercises = 0;
  int _totalReminders = 0;
  bool _isAppActive = true;
  
  final List<Exercise> _exercises = [
    Exercise('Stand and Stretch', 'Stand up and reach your arms overhead, then touch your toes', 60),
    Exercise('Desk Push-ups', 'Place hands on desk, step back and do 10 push-ups', 90),
    Exercise('Squats', 'Stand with feet shoulder-width apart, do 15 squats', 120),
    Exercise('Neck Rolls', 'Gently roll your neck in circles, 5 times each direction', 45),
    Exercise('Calf Raises', 'Rise up on your toes and lower down, repeat 20 times', 60),
    Exercise('Shoulder Shrugs', 'Lift shoulders to ears, hold 3 seconds, repeat 10 times', 45),
    Exercise('Deep Breathing', 'Take 5 deep breaths, hold for 4 seconds each', 60),
    Exercise('Wall Push-ups', 'Face wall, place hands flat against it, do 15 push-ups', 90),
    Exercise('Seated Spinal Twist', 'Sit up straight, twist torso left and right, hold 15 seconds each', 60),
    Exercise('Leg Extensions', 'Sit in chair, extend and lower each leg 10 times', 75),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startReminderTimer();
    _startInactivityTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reminderTimer?.cancel();
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _isAppActive = state == AppLifecycleState.resumed;
    });
    
    if (state == AppLifecycleState.resumed) {
      _updateLastActivityTime();
    }
  }

  void _startReminderTimer() {
    _reminderTimer?.cancel();
    _reminderTimer = Timer.periodic(Duration(minutes: _reminderInterval), (timer) {
      _showReminderNotification();
    });
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      final inactiveMinutes = now.difference(_lastActivityTime).inMinutes;
      
      if (inactiveMinutes >= _reminderInterval && _isAppActive) {
        _showReminderNotification();
      }
    });
  }

  void _updateLastActivityTime() {
    setState(() {
      _lastActivityTime = DateTime.now();
    });
  }

  void _showReminderNotification() {
    if (!_isAppActive) return;
    
    setState(() {
      _totalReminders++;
    });
    
    final randomExercise = _exercises[Random().nextInt(_exercises.length)];
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ReminderDialog(
          exercise: randomExercise,
          onCompleted: () {
            setState(() {
              _completedExercises++;
            });
            _updateLastActivityTime();
            Navigator.of(context).pop();
          },
          onSnooze: () {
            Navigator.of(context).pop();
            Timer(Duration(minutes: 5), () {
              if (_isAppActive) {
                _showReminderNotification();
              }
            });
          },
        );
      },
    );
  }

  void _updateReminderInterval(int newInterval) {
    setState(() {
      _reminderInterval = newInterval;
    });
    _startReminderTimer();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final timeSinceLastActivity = now.difference(_lastActivityTime).inMinutes;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Movement Reminder'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        timeSinceLastActivity < _reminderInterval 
                            ? Icons.check_circle 
                            : Icons.warning,
                        size: 48,
                        color: timeSinceLastActivity < _reminderInterval 
                            ? Colors.green 
                            : Colors.orange,
                      ),
                      SizedBox(height: 12),
                      Text(
                        timeSinceLastActivity < _reminderInterval 
                            ? 'You\'re doing great!' 
                            : 'Time to move!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Last activity: ${timeSinceLastActivity} minutes ago',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Completed',
                      _completedExercises.toString(),
                      Icons.fitness_center,
                      Colors.green,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total Reminders',
                      _totalReminders.toString(),
                      Icons.notifications,
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 20),
              
              // Settings Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reminder Settings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Remind me every $_reminderInterval minutes',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          _buildIntervalButton(15),
                          SizedBox(width: 8),
                          _buildIntervalButton(30),
                          SizedBox(width: 8),
                          _buildIntervalButton(45),
                          SizedBox(width: 8),
                          _buildIntervalButton(60),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Manual Exercise Button
              ElevatedButton(
                onPressed: () {
                  _showReminderNotification();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Get Exercise Now',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              
              SizedBox(height: 12),
              
              // Activity Button
              OutlinedButton(
                onPressed: () {
                  _updateLastActivityTime();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Activity logged! Timer reset.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade600,
                  side: BorderSide(color: Colors.blue.shade600),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Log Activity',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntervalButton(int minutes) {
    final isSelected = _reminderInterval == minutes;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => _updateReminderInterval(minutes),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue.shade600 : Colors.grey.shade200,
          foregroundColor: isSelected ? Colors.white : Colors.grey.shade700,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text('${minutes}m'),
      ),
    );
  }
}

class ReminderDialog extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback onCompleted;
  final VoidCallback onSnooze;

  ReminderDialog({
    required this.exercise,
    required this.onCompleted,
    required this.onSnooze,
  });

  @override
  _ReminderDialogState createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  int _countdown = 0;
  Timer? _countdownTimer;
  bool _exerciseStarted = false;

  @override
  void initState() {
    super.initState();
    _countdown = widget.exercise.duration;
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startExercise() {
    setState(() {
      _exerciseStarted = true;
    });
    
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _countdownTimer?.cancel();
        HapticFeedback.mediumImpact();
        widget.onCompleted();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.fitness_center, color: Colors.blue.shade600, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Time to Move!',
              style: TextStyle(
                color: Colors.blue.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.exercise.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(height: 12),
          Text(
            widget.exercise.description,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          if (_exerciseStarted) ...[
            Center(
              child: Column(
                children: [
                  Text(
                    'Time Remaining:',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${_countdown}s',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade600,
                    ),
                  ),
                  SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: 1.0 - (_countdown / widget.exercise.duration),
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                  ),
                ],
              ),
            ),
          ] else ...[
            Text(
              'Duration: ${widget.exercise.duration} seconds',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (!_exerciseStarted) ...[
          TextButton(
            onPressed: widget.onSnooze,
            child: Text('Snooze 5min'),
          ),
          TextButton(
            onPressed: widget.onCompleted,
            child: Text('Skip'),
          ),
          ElevatedButton(
            onPressed: _startExercise,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text('Start Exercise'),
          ),
        ] else ...[
          TextButton(
            onPressed: widget.onCompleted,
            child: Text('Done Early'),
          ),
        ],
      ],
    );
  }
}

class Exercise {
  final String name;
  final String description;
  final int duration; // in seconds

  Exercise(this.name, this.description, this.duration);
}