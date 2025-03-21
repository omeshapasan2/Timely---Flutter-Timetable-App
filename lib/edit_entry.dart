import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'timetable_entry.dart';

class EditEntryPage extends StatefulWidget {
  final TimetableEntry entry;
  final int index;

  EditEntryPage({required this.entry, required this.index});

  @override
  _EditEntryPageState createState() => _EditEntryPageState();
}

class _EditEntryPageState extends State<EditEntryPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedDay;
  late TimeOfDay _timeFrom;
  late TimeOfDay _timeTo;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _titleController = TextEditingController(text: widget.entry.title);
    _descriptionController =
        TextEditingController(text: widget.entry.description);
    _selectedDay = widget.entry.day;

    // Parse existing time strings to TimeOfDay objects
    _timeFrom = _parseTimeString(widget.entry.timeFrom);
    _timeTo = _parseTimeString(widget.entry.timeTo);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Helper method to parse time strings like "10:30 AM" to TimeOfDay
  TimeOfDay _parseTimeString(String timeStr) {
    // Default fallback
    TimeOfDay defaultTime = TimeOfDay.now();

    try {
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

  // Convert TimeOfDay to formatted string (e.g. "10:30 AM")
  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hourOfPeriod == 0 ? 12 : timeOfDay.hourOfPeriod;
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // Show time picker and update the selected time
  Future<void> _selectTime(BuildContext context, bool isTimeFrom) async {
    final TimeOfDay initialTime = isTimeFrom ? _timeFrom : _timeTo;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      setState(() {
        if (isTimeFrom) {
          _timeFrom = pickedTime;
        } else {
          _timeTo = pickedTime;
        }
      });
    }
  }

  // Save the updated entry
  void _saveEntry() {
    final box = Hive.box('timetableBox');

    // Create updated entry
    final updatedEntry = TimetableEntry(
      title: _titleController.text,
      description: _descriptionController.text,
      day: _selectedDay,
      timeFrom: _formatTimeOfDay(_timeFrom),
      timeTo: _formatTimeOfDay(_timeTo),
    );

    // Update the entry in the Hive box
    box.putAt(widget.index, updatedEntry);

    // Show success message and navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Entry updated successfully')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Timetable Entry'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title input
            Text('Title', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter title',
                border: OutlineInputBorder(),
                filled: true,
              ),
            ),
            SizedBox(height: 16),

            // Day selection
            Text('Day', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedDay,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
              ),
              items: [
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
                'Sunday'
              ].map((String day) {
                return DropdownMenuItem<String>(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    _selectedDay = value;
                  });
                }
              },
            ),
            SizedBox(height: 16),

            // Time selection
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('From',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectTime(context, true),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatTimeOfDay(_timeFrom)),
                              Icon(Icons.access_time),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('To', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectTime(context, false),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatTimeOfDay(_timeTo)),
                              Icon(Icons.access_time),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Description input
            Text('Description (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Enter description',
                border: OutlineInputBorder(),
                filled: true,
              ),
              maxLines: 4,
            ),
            SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveEntry,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
