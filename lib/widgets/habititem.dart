import 'package:flutter/material.dart';
import 'package:advplus/widgets/customcheckbox.dart';
import 'package:advplus/widgets/habitdetails.dart';


class HabitItem extends StatelessWidget {
  final String text;
  final String id; // Requerido para identificar en Firebase
  final bool isChecked;
  final int xp; // XP ganado al completar
  final Map<String, dynamic> habit;
  final ValueChanged<bool?>? onCheckedChange;

  const HabitItem({
    super.key,
    required this.text,
    required this.id,
    required this.isChecked,
    required this.xp,
    required this.habit,
    this.onCheckedChange,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HabitDetailsScreen(habit: habit),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 5),
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            CustomCheckboxImage(
              emptyPath: 'assets/icons/checkbox.png',
              checkmarkPath: 'assets/icons/checkmark.png',
              isChecked: isChecked,
              onTap: onCheckedChange,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Fredoka',
                ),
              ),
            ),
            // Muestra el XP ganado
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                "+$xp XP",
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Fredoka',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
