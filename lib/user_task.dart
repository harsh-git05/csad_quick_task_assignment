import 'dart:async';

import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserTask1 extends StatefulWidget {
  @override
  _UserTaskState createState() => _UserTaskState();
}

class _UserTaskState extends State<UserTask1> {
  final todoController = TextEditingController();
  final descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  DateTime? _selectedDate;

  void _pickDueDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  void addTask() async {
    if (todoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please Provide A Task Name"),
          duration: Duration(seconds: 2),
          backgroundColor: Color.fromARGB(255, 237, 93, 83),
        ),
      );
      return;
    }
    await saveTask(todoController.text, descriptionController.text, _selectedDate);
    setState(() {
      todoController.clear();
      descriptionController.clear();
      _dateController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 251, 252),
      appBar: AppBar(
        title: const Text(
          "QuickTask",
          style: TextStyle(color: Color.fromARGB(255, 123, 154, 241)),
        ),
        backgroundColor: const Color.fromARGB(255, 12, 130, 248),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: const Color.fromARGB(255, 59, 167, 255),
            padding: const EdgeInsets.fromLTRB(17.0, 16.0, 7.0, 16.0),
            child: Column(
              children: [
                TextField(
                  autocorrect: true,
                  textCapitalization: TextCapitalization.sentences,
                  controller: todoController,
                  decoration: const InputDecoration(
                    labelText: "Add A New Task",
                    labelStyle: TextStyle(color: Color.fromARGB(255, 246, 244, 244)),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Due Date',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _pickDueDate,
                    ),
                  ),
                  onTap: _pickDueDate,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(255, 2, 30, 83),
                  ),
                  onPressed: addTask,
                  child: const Text("Add"),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ParseObject>>(
              future: getTask(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text("Error fetching tasks"),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("No tasks available"),
                  );
                } else {
                  return Scrollbar(
                    controller: _scrollController,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final task = snapshot.data![index];
                        final varTitle = task.get<String>('title')!;
                        final varDescription = task.get<String>('description')!;
                        final varDone = task.get<bool>('done') ?? false;

                        return ListTile(
                          title: Text(varTitle),
                          subtitle: Text(varDescription),
                          leading: CircleAvatar(
                            backgroundColor: varDone
                                ? const Color.fromARGB(255, 12, 1, 63)
                                : Colors.black,
                            foregroundColor: Colors.white,
                            child: Icon(varDone ? Icons.check : Icons.assignment),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.black),
                                onPressed: varDone
                                    ? null
                                    : () async {
                                        todoController.text = varTitle;
                                        descriptionController.text = varDescription;
                                        await deleteTask(task.objectId!);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text("Task being edited!"),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                              ),
                              Checkbox(
                                value: varDone,
                                onChanged: (value) async {
                                  await updateTask(task.objectId!, value!);
                                  setState(() {});
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Color.fromARGB(255, 145, 4, 4),
                                ),
                                onPressed: () async {
                                  await deleteTask(task.objectId!);
                                  setState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Task deleted!"),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
          TextButton(
            onPressed: () => doUserLogout(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color.fromARGB(255, 2, 30, 83),
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  Future<void> saveTask(String title, String description, DateTime? dueDate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final task = ParseObject('TaskList')
      ..set('title', title)
      ..set('description', description)
      ..set('username', username)
      ..set('done', false)
      ..set('duedate', dueDate);
    await task.save();
  }

  Future<List<ParseObject>> getTask() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final query = QueryBuilder<ParseObject>(ParseObject('TaskList'))
      ..whereEqualTo('username', username)
      ..orderByAscending('done');
    final response = await query.query();
    return response.success && response.results != null
        ? response.results as List<ParseObject>
        : [];
  }

  Future<void> updateTask(String id, bool done) async {
    final task = ParseObject('TaskList')
      ..objectId = id
      ..set('done', done);
    await task.save();
  }

  Future<void> deleteTask(String id) async {
    final task = ParseObject('TaskList')..objectId = id;
    await task.delete();
  }

  void doUserLogout() async {
    final user = await ParseUser.currentUser() as ParseUser;
    final response = await user.logout();
    if (response.success) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }
}
