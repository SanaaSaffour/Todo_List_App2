import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'tasks_page.dart';

class ToDoScreen extends StatefulWidget {
  @override
  _ToDoScreenState createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  List<String> _categories = ["Work", "Personal", "Shopping"];
  List<int> _categoryIds = [1, 2, 3]; // Corresponding category IDs from the database

  Future<void> _navigateToTasksPage(BuildContext context, int categoryId, String categoryName) async {
    final url = Uri.parse('http://todo-app.atwebpages.com/todo.php?category_id=$categoryId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> tasks = List<Map<String, dynamic>>.from(json.decode(response.body));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TasksPage(categoryName: categoryName, tasks: tasks),
          ),
        );
      } else {
        print('Error fetching tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFBED1E3),
      appBar: AppBar(
        backgroundColor: Color(0XFF93AECA),
        title: Text(
          'To-Do List',
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
          Container(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                String category = _categories[index];
                int categoryId = _categoryIds[index];
                return GestureDetector(
                  onTap: () => _navigateToTasksPage(context, categoryId, category),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Color(0XFF0b1957),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        category,
                        style: TextStyle(
                          color: Color(0xFFBED1E3),
                        ),
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
