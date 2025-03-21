import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:timetable/edit_entry.dart';
import 'dart:async';
import 'timetable_entry.dart';
import 'input.dart';

class DisplayPage extends StatefulWidget {
  @override
  _DisplayPageState createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Update the current time every minute
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7, // Number of tabs (Monday to Sunday)
      initialIndex: _getDayIndex(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Timetable'),
          automaticallyImplyLeading: false, // Remove back button
          bottom: TabBar(
            isScrollable: true, // Allow scrolling if there are many tabs
            tabs: [
              Tab(text: 'Monday'),
              Tab(text: 'Tuesday'),
              Tab(text: 'Wednesday'),
              Tab(text: 'Thursday'),
              Tab(text: 'Friday'),
              Tab(text: 'Saturday'),
              Tab(text: 'Sunday'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildDayTab('Monday'),
            _buildDayTab('Tuesday'),
            _buildDayTab('Wednesday'),
            _buildDayTab('Thursday'),
            _buildDayTab('Friday'),
            _buildDayTab('Saturday'),
            _buildDayTab('Sunday'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => InputPage()),
            );
          },
          child: Icon(Icons.add),
          tooltip: 'Add New Entry',
        ),
      ),
    );
  }

  // Get today's index to set the initial tab
  int _getDayIndex() {
    final weekday = DateTime.now().weekday;
    // Convert to 0-6 index (Monday = 0, Sunday = 6)
    return weekday == 7 ? 6 : weekday - 1;
  }

  // Helper function to build a tab for a specific day
  Widget _buildDayTab(String day) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('timetableBox').listenable(),
      builder: (context, Box box, _) {
        final dayEntries = box.values
            .where((entry) => entry.day == day)
            .cast<TimetableEntry>()
            .toList();

        // Sort entries by time
        dayEntries.sort((a, b) {
          final aTime = _parseTimeString(a.timeFrom);
          final bTime = _parseTimeString(b.timeFrom);
          return aTime.hour * 60 +
              aTime.minute -
              (bTime.hour * 60 + bTime.minute);
        });

        if (dayEntries.isEmpty) {
          return Center(
            child: Text('No tasks for $day'),
          );
        }

        // Find the next upcoming event
        final nextEvent = _findNextEvent(day, dayEntries);

        return Column(
          children: [
            // Current time and countdown to next event
            if (day == _getCurrentDay()) _buildTimeInfoPanel(nextEvent),
            // List of events
            Expanded(
              child: ListView.builder(
                itemCount: dayEntries.length,
                itemBuilder: (context, index) {
                  final entry = dayEntries[index];
                  final entryIndex = box.values.toList().indexOf(entry);
                  final isCurrentEvent = _isCurrentEvent(day, entry);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Slidable(
                      // Slide actions on the right side of the item
                      endActionPane: ActionPane(
                        motion: ScrollMotion(),
                        children: [
                          // Edit action
                          SlidableAction(
                            onPressed: (context) =>
                                _editEntry(context, entry, entryIndex),
                            backgroundColor:
                                const Color.fromARGB(255, 115, 114, 114),
                            foregroundColor: Colors.white,
                            icon: Icons.edit,
                            label: 'Edit',
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                          // Delete action
                          SlidableAction(
                            onPressed: (context) => _deleteEntry(entryIndex),
                            backgroundColor:
                                const Color.fromARGB(255, 163, 161, 161),
                            foregroundColor:
                                const Color.fromARGB(255, 255, 255, 255),
                            icon: Icons.delete,
                            label: 'Delete',
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                        ],
                      ),

                      // The actual item
                      child: Card(
                        margin: EdgeInsets.symmetric(horizontal: 8.0),
                        // Highlight current event
                        color: isCurrentEvent ? Colors.grey[850] : null,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title with larger font
                              Text(
                                entry.title,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 10),
                              // Digital clock style time display
                              Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.access_time_rounded, size: 18),
                                    SizedBox(width: 6),
                                    Text(
                                      '${entry.timeFrom} - ${entry.timeTo}',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                  height: 24,
                                  thickness: 1,
                                  color: Colors.grey[800]),
                              // Styled description
                              if (entry.description.isNotEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[900],
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey[800]!),
                                  ),
                                  child: Text(
                                    entry.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Build the time info panel showing current time and countdown
  Widget _buildTimeInfoPanel(TimetableEntry? nextEvent) {
    String formattedTime =
        "${_currentTime.hour.toString().padLeft(2, '0')}:${_currentTime.minute.toString().padLeft(2, '0')}";

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time_filled, color: Colors.grey[400]),
              SizedBox(width: 8),
              Text(
                'Current Time: $formattedTime',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          if (nextEvent != null) ...[
            SizedBox(height: 8),
            Divider(height: 1, thickness: 1, color: Colors.grey[800]),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.timer_outlined, color: Colors.grey[400]),
                SizedBox(width: 8),
                Text(
                  'Next: ${nextEvent.title}',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                SizedBox(width: 32),
                Text(
                  _getCountdownText(nextEvent),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // Get the current day name
  String _getCurrentDay() {
    final weekday = _currentTime.weekday;
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[weekday - 1];
  }

  // Find the next upcoming event
  TimetableEntry? _findNextEvent(String day, List<TimetableEntry> entries) {
    if (day != _getCurrentDay() || entries.isEmpty) return null;

    for (var entry in entries) {
      final timeFrom = _parseTimeString(entry.timeFrom);
      final currentTimeMinutes = _currentTime.hour * 60 + _currentTime.minute;
      final eventTimeMinutes = timeFrom.hour * 60 + timeFrom.minute;

      if (eventTimeMinutes > currentTimeMinutes) {
        return entry;
      }
    }

    return null; // No upcoming events today
  }

  // Get countdown text to the next event
  String _getCountdownText(TimetableEntry event) {
    final eventTime = _parseTimeString(event.timeFrom);
    final eventDateTime = DateTime(
      _currentTime.year,
      _currentTime.month,
      _currentTime.day,
      eventTime.hour,
      eventTime.minute,
    );

    final difference = eventDateTime.difference(_currentTime);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours > 0) {
      return 'Starting in $hours hr ${minutes > 0 ? '$minutes min' : ''}';
    } else {
      return 'Starting in $minutes min';
    }
  }

  // Check if an event is currently happening
  bool _isCurrentEvent(String day, TimetableEntry entry) {
    if (day != _getCurrentDay()) return false;

    final timeFrom = _parseTimeString(entry.timeFrom);
    final timeTo = _parseTimeString(entry.timeTo);

    final currentTimeMinutes = _currentTime.hour * 60 + _currentTime.minute;
    final eventStartMinutes = timeFrom.hour * 60 + timeFrom.minute;
    final eventEndMinutes = timeTo.hour * 60 + timeTo.minute;

    return currentTimeMinutes >= eventStartMinutes &&
        currentTimeMinutes <= eventEndMinutes;
  }

  // Helper method to parse time strings like "10:30 AM" to TimeOfDay
  TimeOfDay _parseTimeString(String timeStr) {
    // Default fallback
    TimeOfDay defaultTime = TimeOfDay.now();

    try {
      // This is a very basic parser and might need adjustment based on your time format
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);

        // Handle minutes and AM/PM
        String minutesPart = parts[1];
        int minutes = 0;

        if (minutesPart.contains('PM') && hour < 12) {
          hour += 12;
        } else if (minutesPart.contains('AM') && hour == 12) {
          hour = 0;
        }

        // Extract just the numbers for minutes
        final minutesMatch = RegExp(r'(\d+)').firstMatch(minutesPart);
        if (minutesMatch != null) {
          minutes = int.parse(minutesMatch.group(1)!);
        }

        return TimeOfDay(hour: hour, minute: minutes);
      }
    } catch (e) {
      print('Error parsing time: $e');
    }

    return defaultTime;
  }

  void _deleteEntry(int index) async {
    final box = Hive.box('timetableBox');
    await box.deleteAt(index);

    // Show a confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Entry deleted')),
    );
  }

  void _editEntry(BuildContext context, TimetableEntry entry, int index) {
    // Navigate to the input page in edit mode
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEntryPage(entry: entry, index: index),
      ),
    );
  }
}
