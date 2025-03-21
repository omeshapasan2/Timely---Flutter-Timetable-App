import 'package:hive/hive.dart';

part 'timetable_entry.g.dart'; // Include the generated file

@HiveType(typeId: 0)
class TimetableEntry {
  @HiveField(0)
  final String day;

  @HiveField(1)
  final String timeFrom;

  @HiveField(2)
  final String timeTo;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String description;

  TimetableEntry({
    required this.day,
    required this.timeFrom,
    required this.timeTo,
    required this.title,
    required this.description,
  });
}