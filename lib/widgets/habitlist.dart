import 'package:flutter/material.dart';
import 'package:advplus/widgets/habititem.dart';

class HabitList extends StatelessWidget {
  final List<Map<String, dynamic>> habits;
  final Function(int index, bool? value) onCheck;

  const HabitList({super.key, required this.habits, required this.onCheck});

  @override
  Widget build(BuildContext context) {
    // Separar hábitos incompletos y completados con validación segura
    final incompleteHabits = habits.where((habitMap) {
      final completed = habitMap['completed'];
      if (completed is bool) {
        return !completed;
      }
      return true; // Si no es bool o es null → lo tratamos como incompleto
    }).toList();

    final completeHabits = habits.where((habitMap) {
      final completed = habitMap['completed'];
      if (completed is bool) {
        return completed;
      }
      return false; // Si no es bool o es null → no va en completados
    }).toList();

    // Juntamos las listas: incompletos + completados
    final orderedHabits = [...incompleteHabits, ...completeHabits];

    return SizedBox(
      height: 200,
      width: 445,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(226, 12, 12, 12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListView.builder(
          physics: const ClampingScrollPhysics(),
          itemCount: orderedHabits.length,
          itemBuilder: (context, index) {
            final habit = orderedHabits[index];
            final habitName = habit['name'] ?? 'Sin nombre';
            final habitId = habit['id'] ?? '';
            final isChecked = habit['completed'] is bool ? habit['completed'] : false;
            final xp = habit['xp'] is int ? habit['xp'] : 0;

            return HabitItem(
              key: Key('habit_$index'),
              text: habitName,
              habit: habit,
              id: habitId,
              isChecked: isChecked,
              xp: xp,
              onCheckedChange: (value) => onCheck(index, value),
            );
          },
        ),
      ),
    );
  }
}
