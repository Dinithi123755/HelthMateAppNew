import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/common.dart';
import '../domain/health_record.dart';
import 'health_view_model.dart';

class RecordForm extends StatefulWidget {
  const RecordForm({this.record, super.key});
  final HealthRecord? record;
  @override
  State<RecordForm> createState() => _RecordFormState();
}

class _RecordFormState extends State<RecordForm> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _steps;
  late final TextEditingController _calories;
  late final TextEditingController _water;
  late DateTime _date;
  bool _dirty = false;
  bool _saved = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    final row = widget.record;
    _date = row?.date ?? calendarDay(DateTime.now());
    _steps = TextEditingController(text: row?.steps.toString() ?? '0');
    _calories = TextEditingController(text: row?.calories.toString() ?? '0');
    _water = TextEditingController(text: row?.water.toString() ?? '0');
  }

  @override
  void dispose() {
    _steps.dispose();
    _calories.dispose();
    _water.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final vm = context.read<HealthViewModel>();
    final row = HealthRecord(
      id: widget.record?.id,
      date: _date,
      steps: int.parse(_steps.text.trim()),
      calories: int.parse(_calories.text.trim()),
      water: int.parse(_water.text.trim()),
    );
    final success = await vm.save(row);
    if (!mounted) return;
    if (success) {
      setState(() => _saved = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pop(context);
        feedbackMessage(
          context,
          widget.record == null ? 'Record saved.' : 'Record updated.',
        );
      });
    } else {
      setState(() => _error = vm.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<HealthViewModel>().busy;
    return PopScope(
      canPop: _saved || (!_dirty && !busy),
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || busy) return;
        final discard = await confirm(
          context,
          title: 'Discard changes?',
          message: 'Your unsaved activity will be lost.',
          action: 'Discard',
        );
        if (discard && mounted) {
          setState(() => _saved = true);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) Navigator.pop(context);
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.record == null ? 'Add record' : 'Edit record'),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _form,
              onChanged: () {
                if (!_dirty) setState(() => _dirty = true);
              },
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Text(
                    'Enter the date, steps walked, calories burned and water intake.',
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      leading: const Icon(Icons.calendar_month_outlined),
                      title: const Text('Activity date'),
                      subtitle: Text(
                        DateFormat('EEEE, d MMMM yyyy').format(_date),
                      ),
                      trailing: const Icon(Icons.edit_calendar_outlined),
                      onTap: busy
                          ? null
                          : () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _date,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() {
                                  _date = picked;
                                  _dirty = true;
                                });
                              }
                            },
                    ),
                  ),
                  const SizedBox(height: 24),
                  _field(
                    _steps,
                    'Steps walked',
                    'steps',
                    Icons.directions_walk,
                    200000,
                    busy,
                  ),
                  const SizedBox(height: 20),
                  _field(
                    _calories,
                    'Calories burned',
                    'kcal',
                    Icons.local_fire_department_outlined,
                    30000,
                    busy,
                  ),
                  const SizedBox(height: 20),
                  _field(
                    _water,
                    'Water intake',
                    'ml',
                    Icons.water_drop_outlined,
                    20000,
                    busy,
                  ),
                  const SizedBox(height: 12),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    key: const Key('save-record'),
                    onPressed: busy ? null : _save,
                    icon: busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(busy ? 'Saving…' : 'Save record'),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Enter whole numbers. Use 0 for an activity you did not do. At least one value must be above zero.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String unit,
    IconData icon,
    int max,
    bool busy,
  ) => TextFormField(
    controller: controller,
    enabled: !busy,
    keyboardType: TextInputType.number,
    textInputAction: TextInputAction.next,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    decoration: InputDecoration(
      labelText: label,
      suffixText: unit,
      prefixIcon: Icon(icon),
    ),
    validator: (value) => RecordRules.number(value, label.toLowerCase(), max),
  );
}
