import 'package:healthmate/features/records/data/health_repository.dart';
import 'package:healthmate/features/records/domain/health_record.dart';

class MemoryRepository implements HealthRepository {
  List<HealthRecord> rows = [];
  bool fail = false;
  int nextId = 1;
  @override
  Future<List<HealthRecord>> records() async {
    if (fail) throw StateError('Simulated storage failure');
    return [...rows]..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<void> save(HealthRecord record) async {
    if (fail) throw StateError('Simulated storage failure');
    if (record.id != null) rows.removeWhere((r) => r.id == record.id);
    rows.add(
      HealthRecord(
        id: record.id ?? nextId++,
        date: record.date,
        steps: record.steps,
        calories: record.calories,
        water: record.water,
      ),
    );
  }

  @override
  Future<void> delete(int id) async => rows.removeWhere((r) => r.id == id);
}
