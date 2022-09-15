import 'package:flutter/material.dart';
import 'package:flutter_todo/data/local_storage.dart';
import 'package:flutter_todo/main.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';

class TaskItem extends StatefulWidget {
  final Task task;
  const TaskItem({super.key, required this.task});

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  final TextEditingController _taskNameController = TextEditingController();
  late LocalStorage _localStorage;
  @override
  void initState() {
    super.initState();
    _localStorage = locator<LocalStorage>();
  }

  @override
  Widget build(BuildContext context) {
    _taskNameController.text = widget.task.name;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6)
          ]),
      child: ListTile(
        title: widget.task.isComplated
            ? Text(
                widget.task.name,
                style: const TextStyle(
                    decoration: TextDecoration.lineThrough, color: Colors.grey),
              )
            : TextField(
                minLines: 1,
                maxLines: null,
                textInputAction: TextInputAction.done,
                controller: _taskNameController,
                decoration: const InputDecoration(border: InputBorder.none),
                onSubmitted: (value) {
                  _localStorage.updateTask(task: widget.task);
                  widget.task.name = value;
                },
              ),
        trailing: Text(
          DateFormat('MMMM d\nhh:mm a').format(widget.task.createdAt),
          style: const TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.end,
        ),
        leading: GestureDetector(
          onTap: (() {
            widget.task.isComplated = !widget.task.isComplated;
            _localStorage.updateTask(task: widget.task);
            setState(() {});
          }),
          child: Container(
            decoration: BoxDecoration(
                color: widget.task.isComplated ? Colors.green : Colors.white,
                border: Border.all(color: Colors.grey, width: 0.8),
                shape: BoxShape.circle),
            child: const Icon(
              Icons.check,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
