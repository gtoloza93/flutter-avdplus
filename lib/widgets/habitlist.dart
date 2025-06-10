import 'package:flutter/material.dart';
import 'package:advplus/widgets/habititem.dart';

class HabitList extends StatelessWidget {
  final List<Map<String, dynamic>> habits;
  final Function(int index, bool? value) onCheck;

  const HabitList({
    super.key,
    required this.habits,
    required this.onCheck,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(171, 12, 12, 12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        physics: const ClampingScrollPhysics(),
        itemCount: habits.length,
        itemBuilder: (context, index) {
          final habit = habits[index];
          final habitId = habit['id'];
          final xp = habit['xp'] ?? 0;

          return HabitItem(
            key: Key('habit_$index'),
            text: habit['name'],
            id: habitId,
            isChecked: habit['completed'] ?? false,
            xp: xp,
            habit : habit,
            onCheckedChange: (value) => onCheck(index, value),
          );
        },
      ),
    );
  }
}