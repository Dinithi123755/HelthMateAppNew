import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class HealthDatabase {
  HealthDatabase({DatabaseFactory? factory, this.path})
    : _factory = factory ?? databaseFactory;
  final DatabaseFactory _factory;
  final String? path;
  Future<Database>? _opening;
  Future<Database> get database => _opening ??= _open();

  Future<Database> _open() async {
    try {
      final location =
          path ?? p.join(await _factory.getDatabasesPath(), 'healthmate.db');
      return await _factory.openDatabase(
        location,
        options: OpenDatabaseOptions(
          version: 4,
          onUpgrade: (db, oldVersion, newVersion) async {
            if (oldVersion < 2) {
              await db.execute('DROP TABLE IF EXISTS app_settings');
            }
            if (oldVersion < 4) {
              // Preserve user records while removing the obsolete sample column.
              await db.execute(
                'ALTER TABLE health_records RENAME TO old_health_records',
              );
              await db.execute('DROP INDEX IF EXISTS idx_health_records_date');
              await _createRecords(db);
              await db.execute(
                '''INSERT INTO health_records (id, date, steps, calories, water)
                SELECT id, date, steps, calories, water FROM old_health_records
                WHERE is_demo = 0''',
              );
              await db.execute('DROP TABLE old_health_records');
            }
          },
          onCreate: (db, version) => _createRecords(db),
        ),
      );
    } catch (_) {
      _opening = null;
      rethrow;
    }
  }

  Future<void> _createRecords(Database db) async {
    await db.execute('''CREATE TABLE health_records (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT NOT NULL,
      steps INTEGER NOT NULL CHECK(steps BETWEEN 0 AND 200000),
      calories INTEGER NOT NULL CHECK(calories BETWEEN 0 AND 30000),
      water INTEGER NOT NULL CHECK(water BETWEEN 0 AND 20000),
      CHECK(steps + calories + water > 0)
    )''');
    await db.execute(
      'CREATE INDEX idx_health_records_date ON health_records(date)',
    );
  }

  Future<void> close() async {
    final opening = _opening;
    _opening = null;
    if (opening != null) await (await opening).close();
  }
}
