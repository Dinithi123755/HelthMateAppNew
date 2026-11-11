import '../../../core/data/health_database.dart';
import '../domain/health_record.dart';

abstract class HealthRepository {
  Future<List<HealthRecord>> records();
  Future<void> save(HealthRecord record);
  Future<void> delete(int id);
}

class SqliteHealthRepository implements HealthRepository {
  SqliteHealthRepository(this.database, {DateTime Function()? now}) : now = now ?? DateTime.now;
  final HealthDatabase database;
  final DateTime Function() now;
  @override

  Future<List<HealthRecord>> records() async {
    final db = await database.database;
    final rows = await db.query('health_records', 
    orderBy: 'date DESC, id DESC');
    return rows.map(HealthRecord.fromMap).toList();
  }

  @override
  Future<void> save(HealthRecord record) async {
    RecordRules.validate(record, now());
    final db = await database.database;
    if (record.id == null) {
      await db.insert('health_records', record.toMap());
    } else {
      final count = await db.update(
        'health_records',
        record.toMap(),
        where: 'id = ?',
        whereArgs: [record.id],
      );
      if (count != 1) throw StateError('This record no longer exists.');
    }
  }

  @override
  Future<void> delete(int id) async {
    final db = await database.database;
    await db.delete('health_records', where: 'id = ?', whereArgs: [id]);
  }
}
