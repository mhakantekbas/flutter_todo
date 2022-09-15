import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_todo/data/local_storage.dart';
import 'package:flutter_todo/main.dart';
import 'package:flutter_todo/widgets/custom_search_delegate.dart';
import 'package:flutter_todo/widgets/task_list_item.dart';

import '../models/task_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Task> _allTasks;
  late LocalStorage _localStorage;

  @override
  void initState() {
    super.initState();
    _localStorage = locator<LocalStorage>();
    _allTasks = <Task>[];
    getAllTaskFromDb();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: GestureDetector(
            onTap: (() => _showAddTaskBottomSheet(context)),
            child: const Text(
              'Bugün neler yapacaksın?',
              style: TextStyle(color: Colors.black),
            ),
          ),
          centerTitle: false,
          actions: [
            IconButton(
                onPressed: () {
                  _showSearchPage();
                },
                icon: const Icon(Icons.search)),
            IconButton(
                onPressed: () {
                  _showAddTaskBottomSheet(context);
                },
                icon: const Icon(Icons.add))
          ],
        ),
        body: ListView.builder(
          itemBuilder: (context, index) {
            var task = _allTasks[index];
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
                onDismissed: (direciton) {
                  _localStorage.deleteTask(task: task);
                  setState(() {
                    _allTasks.removeAt(index);
                  });
                },
                child: TaskItem(
                  task: task,
                ));
          },
          itemCount: _allTasks.length,
        ));
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    var now = DateTime.now();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context)
                  .viewInsets
                  .bottom), //kalvye ile beraber yükselmesini sağlar
          width: MediaQuery.of(context).size.width,
          child: ListTile(
            title: TextField(
              autofocus: true,
              onSubmitted: ((value) {
                Navigator.of(context).pop();
                DatePicker.showDateTimePicker(
                  minTime: DateTime(now.year, now.month - 1),
                  context,
                  onConfirm: (time) async {
                    var newTask = Task.create(value, time);
                    setState(() {
                      _allTasks.insert(0,
                          newTask); //listede en son eklediğimizi en başa yerleştiirir
                    });
                    await _localStorage.addTask(
                        task: newTask); //ama veritabanında sıra bozulmazz
                  },
                );
              }),
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(hintText: 'Görev nedir'),
            ),
          ),
        );
      },
    );
  }

  void getAllTaskFromDb() async {
    _allTasks = await _localStorage.getAllTask();
    setState(() {});
  }

  Future<void> _showSearchPage() async {
    await showSearch(
        context: context, delegate: CustomSearchDelegate(allTasks: _allTasks));
    getAllTaskFromDb();
  }
}
