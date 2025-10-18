import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskService {
  static const String _tasksKey = 'tasks';
  
  // CREATE - Add new task
  static Future<Task> createTask(String title, String description) async {
    final tasks = await getTasks();
    
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );
    
    tasks.add(newTask);
    await _saveTasks(tasks);
    return newTask;
  }
  
  // READ - Get all tasks
  static Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList(_tasksKey) ?? [];
    
    return tasksJson.map((json) => Task.fromJson(jsonDecode(json))).toList();
  }
  
  // UPDATE - Update existing task
  static Future<Task?> updateTask(Task task) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((t) => t.id == task.id);
    
    if (index != -1) {
      tasks[index] = task;
      await _saveTasks(tasks);
      return task;
    }
    return null;
  }
  
  // DELETE - Remove task
  static Future<bool> deleteTask(String taskId) async {
    final tasks = await getTasks();
    tasks.removeWhere((task) => task.id == taskId);
    await _saveTasks(tasks);
    return true;
  }
  
  // Helper method to save tasks
  static Future<void> _saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = tasks.map((task) => jsonEncode(task.toJson())).toList();
    await prefs.setStringList(_tasksKey, tasksJson);
  }
}
