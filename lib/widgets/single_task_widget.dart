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
    String newTitle =
        title.substring(0, 1).toUpperCase() + title.substring(1).toLowerCase();

    DateTime now = DateTime.now();
    DateTime taskDateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);

    Color cardColor;
    if (isChecked) {
      cardColor = Colors.blue; 
    } else {
      if (now.isAfter(taskDateTime)) {
        cardColor = Colors.red; 
      } else {
        cardColor = Colors.black87; 
      }
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Card(
        elevation: 3,
        color: cardColor.withOpacity(0.8),
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
            '$date $time', // Display both date and time
            style: TextStyle(
              color: Colors.white,
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
