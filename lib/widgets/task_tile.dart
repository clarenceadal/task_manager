import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(task.id),
      leading: Checkbox(
        key: Key('checkbox_${task.id}'),
        value: task.isCompleted,
        onChanged: (_) => onToggle(),
      ),
      title: Text(
        task.title,
        key: Key('title_${task.id}'),
        style: TextStyle(
          decoration: task.isCompleted
              ? TextDecoration.lineThrough
              : TextDecoration.none,
        ),
      ),
      subtitle: Text(task.priority.name.toUpperCase()),
      trailing: IconButton(
        key: Key('delete_${task.id}'),
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
      ),
    );
  }
}
