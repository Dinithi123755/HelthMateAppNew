import 'package:intl/intl.dart';

String dateKey(DateTime value) => DateFormat('yyyy-MM-dd').format(value);
DateTime calendarDay(DateTime value) =>
    DateTime(value.year, value.month, value.day);

class HealthRecord {
  const HealthRecord({
    this.id,
    required this.date,
    required this.steps,
    required this.calories,
    required this.water,
  });
  final int? id;
  final DateTime date;
  final int steps;
  final int calories;
  final int water;

  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'date': dateKey(date),
    'steps': steps,
    'calories': calories,
    'water': water,
  };
  factory HealthRecord.fromMap(Map<String, Object?> map) => HealthRecord(
    id: map['id'] as int,
    date: DateTime.parse(map['date'] as String),
    steps: map['steps'] as int,
    calories: map['calories'] as int,
    water: map['water'] as int,
  );
}

class DailyTotals {
  const DailyTotals({this.steps = 0, this.calories = 0, this.water = 0});
  final int steps;
  final int calories;
  final int water;
  factory DailyTotals.fromRecords(Iterable<HealthRecord> records) =>
      records.fold(
        const DailyTotals(),
        (total, row) => DailyTotals(
          steps: total.steps + row.steps,
          calories: total.calories + row.calories,
          water: total.water + row.water,
        ),
      );
}

class RecordRules {
  static String? number(String? value, String label, int maximum) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Enter $label (use 0 if none).';
    final parsed = int.tryParse(trimmed);
    if (parsed == null) return 'Use a whole number for $label.';
    if (parsed < 0) return '$label cannot be negative.';
    if (parsed > maximum) return 'Maximum $label per entry is $maximum.';
    return null;
  }

  static void validate(HealthRecord record, DateTime today) {
    if (record.date.isBefore(DateTime(2000)) ||
        calendarDay(record.date).isAfter(calendarDay(today))) {
      throw const FormatException('Choose a date from 2000 through today.');
    }
    for (final item in [
      (record.steps, 'steps', 200000),
      (record.calories, 'calories', 30000),
      (record.water, 'water', 20000),
    ]) {
      final error = number('${item.$1}', item.$2, item.$3);
      if (error != null) throw FormatException(error);
    }
    if (record.steps + record.calories + record.water == 0) {
      throw const FormatException('Add at least one activity above zero.');
    }
  }
}
