import 'package:flutter/material.dart';
import 'display.dart';
import 'timetable_entry.dart'; // Import the Hive model
import 'package:hive_flutter/hive_flutter.dart';

class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedDay = 'Monday';
  TimeOfDay _timeFrom = TimeOfDay.now();
  TimeOfDay _timeTo = TimeOfDay.now();

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  Future<void> _selectTime(BuildContext context, bool isFromTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isFromTime ? _timeFrom : _timeTo,
    );
    if (picked != null) {
      setState(() {
        if (isFromTime) {
          _timeFrom = picked;
        } else {
          _timeTo = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedDay,
                items: _days.map((String day) {
                  return DropdownMenuItem<String>(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDay = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Day',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                title: Text('Time From: ${_timeFrom.format(context)}'),
                trailing: Icon(Icons.access_time),
                onTap: () => _selectTime(context, true),
              ),
              SizedBox(height: 10),
              ListTile(
                title: Text('Time To: ${_timeTo.format(context)}'),
                trailing: Icon(Icons.access_time),
                onTap: () => _selectTime(context, false),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_titleController.text.isNotEmpty) {
                    final entry = TimetableEntry(
                      day: _selectedDay,
                      timeFrom: _timeFrom.format(context),
                      timeTo: _timeTo.format(context),
                      title: _titleController.text,
                      description: _descriptionController.text,
                    );

                    // Save entry to Hive
                    final box = Hive.box('timetableBox');
                    await box.add(entry);

                    // Clear the input fields
                    _titleController.clear();
                    _descriptionController.clear();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Entry added successfully!')),
                    );
                  }
                },
                child: Text('Add Entry'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the display page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DisplayPage(),
                    ),
                  );
                },
                child: Text('View Timetable'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
