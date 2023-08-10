import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyGoalsScreen extends StatefulWidget {
  const DailyGoalsScreen({Key? key}) : super(key: key);

  @override
  _DailyGoalsScreenState createState() => _DailyGoalsScreenState();
}

class _DailyGoalsScreenState extends State<DailyGoalsScreen> {
  late List<String> dailyGoals;
  final TextEditingController _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? savedDailyGoals = prefs.getStringList('daily goals');
      if (savedDailyGoals != null) {
        setState(() {
          dailyGoals = savedDailyGoals;
        });
      } else {
        setState(() {
          dailyGoals = [];
        });
      }
    } catch (e) {
      print("Error loading daily goals: $e");
      setState(() {
        dailyGoals = [];
      });
    }
  }

  Future<void> _saveTodos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('daily goals', dailyGoals);
  }

  void _addTodo() {
    if (_todoController.text.isNotEmpty) {
      setState(() {
        dailyGoals.add(_todoController.text);
        _todoController.clear();
        _saveTodos();
      });
    }
  }

  void _toggleTodo(int index) {
    setState(() {
      dailyGoals[index] = dailyGoals[index].startsWith('✓ ')
          ? dailyGoals[index].substring(2)
          : '✓ ${dailyGoals[index]}';
      _saveTodos();
    });
  }

  void _deleteTodo(int index) {
    setState(() {
      dailyGoals.removeAt(index);
      _saveTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Goals')),
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(178, 223, 219, 1.0),
        ),
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: dailyGoals.length,
                  itemBuilder: (context, index) {
                    final isCompleted = dailyGoals[index].startsWith('✓ ');
                    final todoText = isCompleted ? dailyGoals[index].substring(2) : dailyGoals[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0), // Add padding here
                      child: ListTile(
                        title: Text(
                          todoText,
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        leading: IconButton(
                          onPressed: () => _toggleTodo(index),
                          icon: Icon(
                            isCompleted
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: isCompleted ? Colors.teal : Colors.grey,
                            size: 35,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteTodo(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _todoController,
                        decoration: const InputDecoration(
                          labelText: 'Add Daily Goal',
                          labelStyle: TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                          ),
                        ),
                        onSubmitted: (_) {
                          _addTodo();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _addTodo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
