import 'package:diary/screens/task_detail_screen.dart';
import 'package:flutter/material.dart';

class TaskWidget extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay time;
  final bool isChecked;
  final Function(bool) toggleChecked;

  const TaskWidget({
    Key? key,
    required this.title,
    required this.id,
    required this.description,
    required this.time,
    required this.date,
    required this.isChecked,
    required this.toggleChecked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String newTitle = title.substring(0, 1).toUpperCase() + title.substring(1).toLowerCase();

    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Card(
        elevation: 3,
        color: Colors.black87.withOpacity(0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            newTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              decoration: isChecked ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            '$date',
            style: TextStyle(
              color: Colors.white70,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Checkbox(
            value: isChecked,
            onChanged: (bool? newValue) {
              toggleChecked(newValue ?? false);
            },
            activeColor: Colors.blue,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailsScreen(
                  id: id,
                  title: title,
                  description: description,
                  date: date,
                  time: time,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
