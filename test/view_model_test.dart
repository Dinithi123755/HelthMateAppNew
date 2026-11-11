import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/features/records/domain/health_record.dart';
import 'package:healthmate/features/records/presentation/health_view_model.dart';
import 'support/memory_repository.dart';

void main() {
  final today = DateTime(2026, 10, 18);
  late MemoryRepository repository;
  late HealthViewModel vm;
  setUp(() async {
    repository = MemoryRepository();
    vm = HealthViewModel(repository, now: () => today);
    await vm.initialize();
  });
  tearDown(() => vm.dispose());
  test(
    'TC06 daily totals aggregate multiple entries and exclude other days',
    () async {
      await vm.save(
        HealthRecord(date: today, steps: 100, calories: 10, water: 250),
      );
      await vm.save(
        HealthRecord(date: today, steps: 200, calories: 20, water: 500),
      );
      await vm.save(
        HealthRecord(
          date: DateTime(2026, 10, 17),
          steps: 50,
          calories: 5,
          water: 100,
        ),
      );
      expect(vm.todayTotals.steps, 300);
      expect(vm.todayTotals.calories, 30);
      expect(vm.todayTotals.water, 750);
    },
  );
  test('TC07 exact date filtering can be cleared', () async {
    for (var day = 16; day <= 18; day++) {
      await vm.save(
        HealthRecord(
          date: DateTime(2026, 10, day),
          steps: 100,
          calories: 0,
          water: 0,
        ),
      );
    }
    vm.filter(today);
    expect(vm.filtered, hasLength(1));
    vm.filter(null);
    expect(vm.filtered, hasLength(3));
  });
  test(
    'TC08 failed save leaves records unchanged and surfaces recoverable error',
    () async {
      repository.fail = true;
      expect(
        await vm.save(
          HealthRecord(date: today, steps: 10, calories: 0, water: 0),
        ),
        false,
      );
      expect(vm.error, isNotNull);
      expect(vm.busy, false);
      expect(vm.records, isEmpty);
      expect(vm.ready, true);
      repository.fail = false;
      expect(
        await vm.save(
          HealthRecord(date: today, steps: 10, calories: 0, water: 0),
        ),
        true,
      );
      expect(vm.error, isNull);
    },
  );
  test(
    'TC09 numeric validation rejects missing, decimal and nonnumeric input',
    () {
      for (final value in ['', '1.5', 'abc', '-3', '200001']) {
        expect(RecordRules.number(value, 'steps', 200000), isNotNull);
      }
      expect(RecordRules.number(' 100 ', 'steps', 200000), isNull);
      expect(RecordRules.number('0', 'steps', 200000), isNull);
    },
  );
  test(
    'TC10 calendar-day windows cross year boundary and update on midnight',
    () async {
      var current = DateTime(2026, 12, 31, 23, 59);
      final clockVm = HealthViewModel(repository, now: () => current);
      await clockVm.initialize();
      await clockVm.save(
        HealthRecord(date: current, steps: 20, calories: 0, water: 0),
      );
      current = DateTime(2027, 1, 1);
      expect(clockVm.todayTotals.steps, 0);
      clockVm.dispose();
    },
  );
}
