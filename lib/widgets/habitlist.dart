import 'package:flutter/material.dart';
import 'package:advplus/widgets/habititem.dart';

class HabitList extends StatelessWidget {
  final List<Map<String, dynamic>> habits;
  final Function(int index, bool? value) onCheck;

  const HabitList({super.key, required this.habits, required this.onCheck});

  @override
  Widget build(BuildContext context) {
    // Separar hábitos incompletos y completados
    final incompleteHabits =
        habits.where((h) => !(h['completed'] ?? false)).toList();
    final completeHabits =
        habits.where((h) => h['completed'] ?? false).toList();

    // Juntamos con el orden correcto: incompletos + completados
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
              return HabitItem(
              text: habit['name'],
              habit: habit,
              id: habit['id'],
              isChecked: habit['completed'] ?? false,
              xp: habit['xp'] ?? 0,
              onCheckedChange: (value) => onCheck(index, value),
            );
          },
        ),
      ),
    );
  }
}
