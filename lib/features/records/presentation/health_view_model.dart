import 'package:flutter/foundation.dart';
import '../data/health_repository.dart';
import '../domain/health_record.dart';

class HealthViewModel extends ChangeNotifier {
  HealthViewModel(this.repository, {DateTime Function()? now}) : now = now ?? DateTime.now;
  final HealthRepository repository;
  final DateTime Function() now;
  List<HealthRecord> _records = [];
  List<HealthRecord> get records => List.unmodifiable(_records);
  bool loading = true;
  bool ready = false;
  bool busy = false;
  String? error;
  DateTime? selectedDate;
  DateTime get today => calendarDay(now());
  List<HealthRecord> get filtered => selectedDate == null ? records : onDate(selectedDate!);

  List<HealthRecord> onDate(DateTime day) =>
      _records.where((row) => dateKey(row.date) == dateKey(day)).toList();
  DailyTotals totalsOn(DateTime day) => DailyTotals.fromRecords(onDate(day));
  DailyTotals get todayTotals => totalsOn(today);

  void filter(DateTime? date) {
    selectedDate = date == null ? null : calendarDay(date);
    notifyListeners();
  }

  Future<void> initialize() async {
    loading = true;
    ready = false;
    error = null;
    notifyListeners();
    try {
      _records = await repository.records();
      ready = true;
    } catch (_) {
      error = 'Could not open your local data. Please try again.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> _change(Future<void> Function() action) async {
    if (busy) return false;
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
      _records = await repository.records();
      return true;
    } on FormatException catch (e) {
      error = e.message;
      return false;
    } catch (_) {
      error = 'Could not complete the change. Check your records before trying again.';
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<bool> save(HealthRecord row) => _change(() async {
    RecordRules.validate(row, now());
    await repository.save(row);
  });
  Future<bool> delete(HealthRecord row) => _change(() => repository.delete(row.id!));
  void refreshDate() => notifyListeners();
}
