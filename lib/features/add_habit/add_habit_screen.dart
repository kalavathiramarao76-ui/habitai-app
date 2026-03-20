import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import 'package:habit_coach/core/design/app_colors.dart';
import 'package:habit_coach/core/design/app_spacing.dart';
import 'package:habit_coach/core/models/habit.dart';
import 'package:habit_coach/core/providers/habit_provider.dart';
import 'package:habit_coach/core/widgets/app_button.dart';
import 'package:habit_coach/core/widgets/celebration_overlay.dart';

class _PopularHabit {
  const _PopularHabit(this.emoji, this.name);
  final String emoji;
  final String name;
}

const _popularHabits = [
  _PopularHabit('\u{1F4AA}', 'Exercise'),
  _PopularHabit('\u{1F4D6}', 'Read'),
  _PopularHabit('\u{1F9D8}', 'Meditate'),
  _PopularHabit('\u{1F4A7}', 'Drink Water'),
  _PopularHabit('\u{1F3C3}', 'Run'),
  _PopularHabit('\u{270D}\u{FE0F}', 'Journal'),
  _PopularHabit('\u{1F3B5}', 'Practice Music'),
  _PopularHabit('\u{1F34E}', 'Eat Healthy'),
  _PopularHabit('\u{1F634}', 'Sleep 8hrs'),
  _PopularHabit('\u{1F4F1}', 'No Phone'),
];

const _emojiGrid = [
  '\u{1F4AA}', '\u{1F3C3}', '\u{1F9D8}', '\u{1F4D6}', '\u{270D}\u{FE0F}',
  '\u{1F4A7}', '\u{1F34E}', '\u{1F634}', '\u{1F3B5}', '\u{1F3A8}',
  '\u{1F4BB}', '\u{1F4F1}', '\u{1F305}', '\u{1F319}', '\u{2B50}',
  '\u{1F525}', '\u{1F4A1}', '\u{1F3AF}', '\u{1F3C6}', '\u{1F4B0}',
  '\u{1F4CA}', '\u{1F9E0}', '\u{2764}\u{FE0F}', '\u{1F33F}',
];

const _unitOptions = ['minutes', 'glasses', 'pages', 'reps', 'km', 'times'];

const _weekDayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final _nameController = TextEditingController();
  String _selectedEmoji = '\u{1F31F}';
  int _selectedColorIndex = 0;
  HabitFrequency _frequency = HabitFrequency.daily;
  final Set<int> _selectedDays = {};
  int _timesPerWeek = 3;
  HabitTimeOfDay _timeOfDay = HabitTimeOfDay.anytime;
  TimeOfDay? _reminderTime;
  bool _isMeasurable = false;
  final _targetValueController = TextEditingController();
  String _selectedUnit = 'minutes';

  @override
  void dispose() {
    _nameController.dispose();
    _targetValueController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a habit name')),
      );
      return;
    }

    final color = AppColors.habitColors[_selectedColorIndex].color;
    String? reminder;
    if (_reminderTime != null) {
      reminder =
          '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}';
    }

    double? targetValue;
    if (_isMeasurable) {
      targetValue = double.tryParse(_targetValueController.text.trim());
    }

    final habit = Habit(
      id: const Uuid().v4(),
      name: name,
      icon: _selectedEmoji,
      colorValue: color.toARGB32(),
      frequency: _frequency,
      targetDays: _frequency == HabitFrequency.specificDays
          ? (_selectedDays.toList()..sort())
          : [],
      timesPerPeriod: _frequency == HabitFrequency.timesPerWeek
          ? _timesPerWeek
          : 1,
      timeOfDay: _timeOfDay,
      reminderTime: reminder,
      measurable: _isMeasurable,
      unit: _isMeasurable ? _selectedUnit : null,
      targetValue: _isMeasurable ? targetValue : null,
    );

    await ref.read(habitsProvider.notifier).addHabit(habit);

    if (mounted) {
      CelebrationOverlay.show(context);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) context.pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create a Habit'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── STEP 1: What habit? ─────────────────────────────
            Text(
              'What habit do you want to build?',
              style: theme.textTheme.headlineSmall,
            ),
            AppSpacing.vGap16,
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'e.g. Exercise, Read, Meditate',
                prefixIcon: Icon(Icons.edit_rounded),
              ),
            ),
            AppSpacing.vGap16,
            Text(
              'Popular habits',
              style: theme.textTheme.titleSmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            AppSpacing.vGap8,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _popularHabits.map((h) {
                return ActionChip(
                  label: Text('${h.emoji} ${h.name}'),
                  onPressed: () {
                    setState(() {
                      _nameController.text = h.name;
                      _selectedEmoji = h.emoji;
                    });
                  },
                );
              }).toList(),
            ),

            AppSpacing.vGap32,

            // ── STEP 2: Customize ───────────────────────────────
            Text('Emoji', style: theme.textTheme.titleMedium),
            AppSpacing.vGap8,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emojiGrid.map((emoji) {
                final selected = _selectedEmoji == emoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = emoji),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? cs.primaryContainer
                          : cs.surfaceContainerHighest,
                      border: selected
                          ? Border.all(color: cs.primary, width: 2)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                  ),
                );
              }).toList(),
            ),

            AppSpacing.vGap24,
            Text('Color', style: theme.textTheme.titleMedium),
            AppSpacing.vGap8,
            Row(
              children: List.generate(AppColors.habitColors.length, (i) {
                final color = AppColors.habitColors[i].color;
                final selected = _selectedColorIndex == i;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedColorIndex = i),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
                      child: selected
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  ),
                );
              }),
            ),

            AppSpacing.vGap32,

            // ── STEP 3: Schedule ────────────────────────────────
            Text('Schedule', style: theme.textTheme.titleMedium),
            AppSpacing.vGap12,
            Text(
              'Frequency',
              style: theme.textTheme.titleSmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            AppSpacing.vGap8,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FrequencyChip(
                  label: 'Daily',
                  selected: _frequency == HabitFrequency.daily,
                  onTap: () =>
                      setState(() => _frequency = HabitFrequency.daily),
                ),
                _FrequencyChip(
                  label: 'Specific Days',
                  selected: _frequency == HabitFrequency.specificDays,
                  onTap: () =>
                      setState(() => _frequency = HabitFrequency.specificDays),
                ),
                _FrequencyChip(
                  label: 'X per Week',
                  selected: _frequency == HabitFrequency.timesPerWeek,
                  onTap: () =>
                      setState(() => _frequency = HabitFrequency.timesPerWeek),
                ),
              ],
            ),

            if (_frequency == HabitFrequency.specificDays) ...[
              AppSpacing.vGap12,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (i) {
                  final day = i + 1; // 1=Mon..7=Sun
                  final selected = _selectedDays.contains(day);
                  return FilterChip(
                    label: Text(_weekDayLabels[i]),
                    selected: selected,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedDays.add(day);
                        } else {
                          _selectedDays.remove(day);
                        }
                      });
                    },
                  );
                }),
              ),
            ],

            if (_frequency == HabitFrequency.timesPerWeek) ...[
              AppSpacing.vGap12,
              Row(
                children: [
                  Text(
                    '$_timesPerWeek times per week',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _timesPerWeek > 1
                        ? () => setState(() => _timesPerWeek--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '$_timesPerWeek',
                    style: theme.textTheme.titleLarge,
                  ),
                  IconButton(
                    onPressed: _timesPerWeek < 7
                        ? () => setState(() => _timesPerWeek++)
                        : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],

            AppSpacing.vGap16,
            Text(
              'Time of day',
              style: theme.textTheme.titleSmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            AppSpacing.vGap8,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _TimeChip(
                  label: '\u{2600}\u{FE0F} Morning',
                  selected: _timeOfDay == HabitTimeOfDay.morning,
                  onTap: () =>
                      setState(() => _timeOfDay = HabitTimeOfDay.morning),
                ),
                _TimeChip(
                  label: '\u{1F324}\u{FE0F} Afternoon',
                  selected: _timeOfDay == HabitTimeOfDay.afternoon,
                  onTap: () =>
                      setState(() => _timeOfDay = HabitTimeOfDay.afternoon),
                ),
                _TimeChip(
                  label: '\u{1F319} Evening',
                  selected: _timeOfDay == HabitTimeOfDay.evening,
                  onTap: () =>
                      setState(() => _timeOfDay = HabitTimeOfDay.evening),
                ),
                _TimeChip(
                  label: '\u{23F0} Anytime',
                  selected: _timeOfDay == HabitTimeOfDay.anytime,
                  onTap: () =>
                      setState(() => _timeOfDay = HabitTimeOfDay.anytime),
                ),
              ],
            ),

            AppSpacing.vGap16,
            TextButton.icon(
              onPressed: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _reminderTime ?? TimeOfDay.now(),
                );
                if (picked != null) {
                  setState(() => _reminderTime = picked);
                }
              },
              icon: const Icon(Icons.notifications_outlined),
              label: Text(
                _reminderTime != null
                    ? 'Reminder: ${_reminderTime!.format(context)}'
                    : 'Set Reminder',
              ),
            ),

            AppSpacing.vGap32,

            // ── STEP 4: Goal ────────────────────────────────────
            Text('Goal (optional)', style: theme.textTheme.titleMedium),
            AppSpacing.vGap8,
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Track a measurable goal?'),
              value: _isMeasurable,
              onChanged: (val) => setState(() => _isMeasurable = val),
            ),

            if (_isMeasurable) ...[
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _targetValueController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        hintText: 'Target value',
                      ),
                    ),
                  ),
                  AppSpacing.hGap12,
                  Expanded(
                    flex: 3,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _unitOptions.map((unit) {
                        return ChoiceChip(
                          label: Text(unit),
                          selected: _selectedUnit == unit,
                          onSelected: (_) =>
                              setState(() => _selectedUnit = unit),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],

            AppSpacing.vGap32,

            // ── Bottom: Save ────────────────────────────────────
            AppButton(
              label: 'Start Tracking',
              size: AppButtonSize.large,
              expand: true,
              leadingIcon: Icons.rocket_launch_rounded,
              onPressed: _save,
            ),
            AppSpacing.vGap32,
          ],
        ),
      ),
    );
  }
}

class _FrequencyChip extends StatelessWidget {
  const _FrequencyChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
