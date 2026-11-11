import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:healthmate/core/data/health_database.dart';
import 'package:healthmate/features/records/data/health_repository.dart';
import 'package:healthmate/features/records/domain/health_record.dart';

void main() {
  sqfliteFfiInit();
  final today = DateTime(2026, 10, 18);
  late HealthDatabase database;
  late SqliteHealthRepository repository;
  setUp(() {
    database = HealthDatabase(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    repository = SqliteHealthRepository(database, now: () => today);
  });
  tearDown(() => database.close());

  test('TC01 creates, reads, updates and deletes a SQLite record', () async {
    await repository.save(
      HealthRecord(date: today, steps: 1000, calories: 80, water: 250),
    );
    var rows = await repository.records();
    expect(rows, hasLength(1));
    expect(rows.single.id, isNotNull);
    await repository.save(
      HealthRecord(
        id: rows.single.id,
        date: today,
        steps: 2000,
        calories: 100,
        water: 500,
      ),
    );
    rows = await repository.records();
    expect(rows.single.steps, 2000);
    expect(rows.single.water, 500);
    await repository.delete(rows.single.id!);
    expect(await repository.records(), isEmpty);
  });
  test(
    'TC02 rejects negative, excessive, empty-activity and future records',
    () async {
      for (final record in [
        HealthRecord(date: today, steps: -1, calories: 1, water: 0),
        HealthRecord(date: today, steps: 200001, calories: 0, water: 0),
        HealthRecord(date: today, steps: 0, calories: 0, water: 0),
        HealthRecord(
          date: today.add(const Duration(days: 1)),
          steps: 1,
          calories: 0,
          water: 0,
        ),
      ]) {
        await expectLater(repository.save(record), throwsFormatException);
      }
      expect(await repository.records(), isEmpty);
    },
  );
  test('TC04 records survive database close and reopen', () async {
    final temp = await Directory.systemTemp.createTemp('healthmate_test_');
    final path = '${temp.path}/persistence.db';
    final disk = HealthDatabase(factory: databaseFactoryFfi, path: path);
    final first = SqliteHealthRepository(disk, now: () => today);
    try {
      await first.save(
        HealthRecord(date: today, steps: 12, calories: 0, water: 300),
      );
      await disk.close();
      final reopened = HealthDatabase(factory: databaseFactoryFfi, path: path);
      try {
        final second = SqliteHealthRepository(reopened, now: () => today);
        expect((await second.records()).single.water, 300);
      } finally {
        await reopened.close();
      }
    } finally {
      await disk.close();
      await temp.delete(recursive: true);
    }
  });
  test(
    'TC05 SQLite constraints protect data even outside UI validation',
    () async {
      final db = await database.database;
      await expectLater(
        db.insert('health_records', {
          'date': '2026-10-18',
          'steps': -1,
          'calories': 0,
          'water': 1,
        }),
        throwsA(isA<DatabaseException>()),
      );
    },
  );
}
