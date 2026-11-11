import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/common.dart';
import '../domain/health_record.dart';
import 'health_view_model.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });
  final VoidCallback onAdd;
  final ValueChanged<HealthRecord> onEdit;
  final ValueChanged<HealthRecord> onDelete;
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HealthViewModel>();
    final rows = vm.filtered;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Text(
          'Health records',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(
                vm.selectedDate == null
                    ? 'Filter by date'
                    : DateFormat.yMMMd().format(vm.selectedDate!),
              ),
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: vm.selectedDate ?? vm.today,
                  firstDate: DateTime(2000),
                  lastDate: vm.today,
                );
                if (date != null) vm.filter(date);
              },
            ),
            if (vm.selectedDate != null)
              TextButton(
                onPressed: () => vm.filter(null),
                child: const Text('Show all'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text('${rows.length} records'),
        const SizedBox(height: 12),
        if (rows.isEmpty)
          EmptyState(
            title: 'No records',
            message: vm.selectedDate == null
                ? 'Add a health record to get started.'
                : 'No records for this date.',
            action: TextButton(
              onPressed: onAdd,
              child: const Text('Add record'),
            ),
          )
        else
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RecordCard(
                record: row,
                onEdit: () => onEdit(row),
                onDelete: () => onDelete(row),
              ),
            ),
          ),
      ],
    );
  }
}
