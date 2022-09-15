import 'package:flutter/material.dart';
import 'package:flutter_todo/data/local_storage.dart';
import 'package:flutter_todo/main.dart';
import 'package:flutter_todo/models/task_model.dart';
import 'package:flutter_todo/widgets/task_list_item.dart';

class CustomSearchDelegate extends SearchDelegate {
  final List<Task> allTasks;

  CustomSearchDelegate({required this.allTasks});
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query.isEmpty ? null : query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return GestureDetector(
      onTap: () => close(context, null),
      child: const Icon(
        Icons.arrow_back_ios,
        color: Colors.black,
        size: 24,
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Task> filteredList = allTasks
        .where(
          (task) => task.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    return ListView.builder(
      itemBuilder: (context, index) {
        var task = filteredList[index];
        return Dismissible(
            background: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.delete,
                  color: Colors.grey,
                ),
                Text('Bu görev silindi')
              ],
            ),
            key: Key(task.id),
            onDismissed: (direciton) async {
              filteredList.removeAt(index);
              await locator<LocalStorage>().deleteTask(task: task);
            },
            child: TaskItem(
              task: task,
            ));
      },
      itemCount: filteredList.length,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return query.isEmpty ? Container() : buildResults(context);
  }
}
