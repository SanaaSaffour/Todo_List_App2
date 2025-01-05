import 'package:flutter/material.dart';

class TasksPage extends StatefulWidget {
  final String categoryName;
  final List<Map<String, dynamic>> tasks;

  TasksPage({required this.categoryName, required this.tasks});

  @override
  _TasksPageState createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with TickerProviderStateMixin {
  String _searchQuery = ""; // For task search
  late List<Map<String, dynamic>> _tasks; // Original task list
  late List<Map<String, dynamic>> _filteredTasks; // Filtered task list

  @override
  void initState() {
    super.initState();
    _tasks = widget.tasks.map((task) {
      task['priority'] ??= 'Medium'; // Default priority if none exists
      return task;
    }).toList();
    _filteredTasks = _tasks; // Initially, show all tasks
  }

  void _updateSearch(String query) {
    setState(() {
      _searchQuery = query;
      if (_searchQuery.isEmpty) {
        _filteredTasks = _tasks; // Reset to all tasks if search is empty
      } else {
        _filteredTasks = _tasks
            .where((task) =>
            task['name'].toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList(); // Filter tasks by name
      }
    });
  }

  void _setPriority(int index, String priority) {
    setState(() {
      _tasks[index]['priority'] = priority;
      _sortTasksByPriority();
    });
  }

  void _sortTasksByPriority() {
    _tasks.sort((a, b) {
      const priorityOrder = {'High': 1, 'Medium': 2, 'Low': 3};
      return priorityOrder[a['priority']]!.compareTo(priorityOrder[b['priority']]!);
    });
    _filteredTasks = _searchQuery.isEmpty
        ? _tasks
        : _tasks
        .where((task) =>
        task['name'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _markTaskComplete(int index) {
    setState(() {
      _filteredTasks[index]['done'] = 1; // Update task as completed
    });

    // Trigger completion animation
    showDialog(
      context: context,
      builder: (context) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: AnimationController(
              vsync: this,
              duration: Duration(milliseconds: 500),
            )..forward(),
            curve: Curves.easeOutBack,
          ),
          child: AlertDialog(
            backgroundColor: Colors.greenAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 60, color: Colors.white),
                SizedBox(height: 10),
                Text(
                  "Task Completed!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.redAccent;
      case 'Medium':
        return Colors.orangeAccent;
      case 'Low':
        return Colors.greenAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0XFF93AECA),
        title: Text(
          '${widget.categoryName} Tasks',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color(0XFF0b1957),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: _updateSearch,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          // Task List
          Expanded(
            child: _filteredTasks.isEmpty
                ? Center(
              child: Text(
                "No tasks found!",
                style: TextStyle(fontSize: 20, color: Color(0XFFD29E9E)),
              ),
            )
                : ListView.builder(
              itemCount: _filteredTasks.length,
              itemBuilder: (context, index) {
                var task = _filteredTasks[index];
                return GestureDetector(
                  onTap: task['done'] == 1
                      ? null // Task is already completed
                      : () => _markTaskComplete(index),
                  child: Card(
                    margin: EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: task['done'] == 1
                        ? Color(0XFFEAD0D1)
                        : Colors.white,
                    elevation: 5,
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      title: Text(
                        task['name'],
                        style: TextStyle(
                          decoration: task['done'] == 1
                              ? TextDecoration.lineThrough
                              : null,
                          color: task['done'] == 1
                              ? Colors.grey
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: DropdownButton<String>(
                        value: task['priority'],
                        underline: SizedBox(),
                        items: ['High', 'Medium', 'Low']
                            .map((priority) => DropdownMenuItem<String>(
                          value: priority,
                          child: Text(
                            priority,
                            style: TextStyle(
                              color: _getPriorityColor(priority),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ))
                            .toList(),
                        onChanged: (value) =>
                            _setPriority(index, value!),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
